{
  description = "Bolt-Foundry unified dev environment";

  ########################
  ## 1. Inputs
  ########################
  inputs = {
    nixpkgs.url          = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url      = "github:numtide/flake-utils";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  ########################
  ## 2. Outputs
  ########################
  outputs = { self, nixpkgs, flake-utils, nixpkgs-unstable, ... }:
    let
      ##################################################################
      # 2a.  Package sets - Now directly defined
      ##################################################################
      
      mkBaseDeps = { pkgs, system }:
        let
          unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
        in
        [
          unstable.deno  # Use deno from unstable
          pkgs.git
        ];

      # everythingExtra = "stuff on top of base"
      mkEverythingExtra = { pkgs, system }:
        let
          lib = pkgs.lib;
          unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
        in
        [
          pkgs.unzip
          pkgs.jupyter
          pkgs.jq
          pkgs.direnv
          pkgs.nix-direnv
          pkgs.sapling
          pkgs.gh
          pkgs.python311Packages.tiktoken
          pkgs.nodejs_22
          pkgs.pnpm
          pkgs._1password-cli
          pkgs.typescript-language-server
          pkgs.ffmpeg
          pkgs.nettools
          pkgs.ripgrep
          pkgs.fd
          pkgs.lsof
          pkgs.openssh
          pkgs.bind.dnsutils  # Provides nslookup and dig
          pkgs.ruby_3_3  # Ruby for kamal deployment tool
        ] ++ lib.optionals pkgs.stdenv.isDarwin [
          # Darwin-specific packages  
          unstable.container
        ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [
          # Linux-only packages
          pkgs.chromium
          pkgs.iproute2
          pkgs.libcap  # For setcap to allow binding to privileged ports
          unstable.openvscode-server
        ];

      ##################################################################
      # 2b.  Helpers
      ##################################################################
      # mkShellWith extras → dev-shell whose buildInputs = baseDeps ++ extras

      mkShellWith = { pkgs, system
        , extras ? [ ]
        , hookName ? "Shell"
        , env ? { }
        , shellHookExtra ? ""
        , autoSyncSitevars ? true
        }:
      let
        baseDeps = mkBaseDeps { inherit pkgs system; };
      in
      pkgs.mkShell
      (env // {
        buildInputs = baseDeps ++ extras;
        shellHook = ''
          # nice banner
          echo -e "\\e[1;34m[${hookName}]\\e[0m  \\
          base:${toString (map (p: p.name or "<pkg>") baseDeps)}  \\
          extras:${toString (map (p: p.name or "<pkg>") extras)}"

          # Set up Bolt Foundry environment
          # Only set BF_ROOT if not already set (allows parent directories to override)
          export BF_ROOT="''${BF_ROOT:-$PWD}"
          
          # Set BOLT_FOUNDRY_ROOT to parent directory if we're in bfmono
          if [[ "$PWD" == */bfmono ]]; then
            export BOLT_FOUNDRY_ROOT="$(dirname "$PWD")"
          else
            export BOLT_FOUNDRY_ROOT="$PWD"
          fi
          
          export PATH="$BF_ROOT/bin:$BF_ROOT/infra/bin:$BOLT_FOUNDRY_ROOT/infra/bin:$PATH"
          # Use Deno defaults for cache directory
          export GH_REPO="bolt-foundry/bfmono"
          
          # Set default E2E test artifact location for stable test results
          export BF_E2E_LATEST_DIR="$BF_ROOT/shared/latest-e2e"

          # Function to load env file if it exists
          load_env_if_exists() {
            if [ -f "$1" ]; then
              echo "📄 Loading $1..."
              set -a  # automatically export all variables
              source "$1"
              set +a
            fi
          }

          # Load environment files in order (later overrides earlier)
          load_env_if_exists "$BF_ROOT/.env.config.example"  # Safe defaults
          load_env_if_exists "$BF_ROOT/.env.secrets.example" # Safe defaults
          load_env_if_exists "$BF_ROOT/.env.config"          # From 1Password
          load_env_if_exists "$BF_ROOT/.env.secrets"         # From 1Password
          load_env_if_exists "$BF_ROOT/.env.local"           # User overrides

          # Warn if no env files are present
          if [ ! -f "$BF_ROOT/.env.config" ] && [ ! -f "$BF_ROOT/.env.secrets" ]; then
            echo "⚠️  No .env files found (.env.config/.env.secrets)."
            echo "   Provide env files manually or via your preferred secret sync."
          fi

          # Ensure RubyGems user bin is on PATH so 'kamal' is found in every shell
          if command -v ruby >/dev/null 2>&1; then
            GEM_USER_BIN="$(ruby -e 'print Gem.user_dir')/bin"
            case ":$PATH:" in
              *":$GEM_USER_BIN:"*) ;; # already present
              *) export PATH="$PATH:$GEM_USER_BIN" ;;
            esac
          fi

          # Auto-install Deno Jupyter kernel (opt-in)
          # Enable with: export BF_AUTO_INSTALL_DENO_JUPYTER=1
          if [ "''${BF_AUTO_INSTALL_DENO_JUPYTER:-0}" = "1" ]; then
            if command -v jupyter >/dev/null 2>&1 && command -v deno >/dev/null 2>&1; then
              # Use POSIX character classes instead of PCRE escapes to avoid control characters
              if ! jupyter kernelspec list 2>/dev/null | grep -qE '^[[:space:]]*deno([[:space:]]|$)'; then
                echo "🧪 Installing Deno Jupyter kernel (first-run)..."
                _BF_DEBUG_SAVED="$DEBUG"; unset DEBUG || true
                if ! deno jupyter --install >/dev/null 2>&1; then
                  deno jupyter --unstable --install >/dev/null 2>&1 || true
                fi
                if [ -n "$_BF_DEBUG_SAVED" ]; then export DEBUG="$_BF_DEBUG_SAVED"; fi
              fi
            fi
          fi

          ${shellHookExtra}
        '';
      });
    in

    ############################################################
    # 2c.  Per-system dev shells
    ############################################################
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        everythingExtra = mkEverythingExtra { inherit pkgs system; };
      in {
        devShells = rec {
          # canonical minimal environment
          base            = mkShellWith { inherit pkgs system; hookName = "Base shell"; };

          # codex = same as base
          codex           = mkShellWith { inherit pkgs system; hookName = "Codex shell"; };

          # full tool-chain variants
          everything      = mkShellWith { inherit pkgs system; extras = everythingExtra; hookName = "Everything shell"; };
          replit          = mkShellWith { inherit pkgs system; extras = everythingExtra; hookName = "Replit shell"; };
          
          # CI environment (vault determined by OP_SERVICE_ACCOUNT_TOKEN)
          github-actions  = mkShellWith { 
            inherit pkgs system; 
            extras = everythingExtra; 
            hookName = "GitHub-Actions shell";
          };

          # Production environment (vault determined by OP_SERVICE_ACCOUNT_TOKEN)
          production = mkShellWith {
            inherit pkgs system;
            extras = everythingExtra;
            hookName = "Production shell";
          };

          # Container environment (minimal, no auto-sync)
          container = mkShellWith {
            inherit pkgs system;
            extras = everythingExtra;
            hookName = "Container shell";
            autoSyncSitevars = false;  # Container should have pre-baked env
          };

          # legacy alias
          default         = everything;
        };

        # FlakeHub-cached build packages
        packages = rec {
          # Build the main web application
          web = pkgs.stdenv.mkDerivation {
            pname = "bolt-foundry-web";
            version = "0.1.0";
            src = ./.;
            nativeBuildInputs = with pkgs; [ pkgs.deno ];
            buildPhase = ''
              deno task build:web
            '';
            installPhase = ''
              mkdir -p $out/bin
              cp build/web $out/bin/ || echo "No web binary found"
              cp -r static $out/ || echo "No static directory found"
            '';
          };

          # Build the marketing site
          boltfoundry-com = pkgs.stdenv.mkDerivation {
            pname = "boltfoundry-com";
            version = "0.1.0";
            src = ./.;
            nativeBuildInputs = with pkgs; [ pkgs.deno ];
            buildPhase = ''
              deno task build:boltfoundry-com
            '';
            installPhase = ''
              mkdir -p $out/bin
              cp build/boltfoundry-com $out/bin/ || echo "No boltfoundry-com binary found"
            '';
          };

          # Profile script setup using runCommand to create proper structure
          codebot-profile = pkgs.runCommand "codebot-profile-setup" {} ''
            mkdir -p $out/etc/profile.d
            cat > $out/etc/profile.d/codebot-init.sh << 'EOF'
            # Claude Code environment initialization
            if [ "$CODEBOT_INITIALIZED" != "1" ]; then
              export CODEBOT_INITIALIZED=1
              
              # Set up Claude config files if they exist in workspace
              if [ -f "/workspace/claude.json" ]; then
                ln -sf /workspace/claude.json /root/.claude.json
              fi
              
              if [ -d "/workspace/claude" ]; then
                ln -sf /workspace/claude /root/.claude
              fi
              
              # Change to workspace directory
              if [ -d "/workspace" ]; then
                cd /workspace
              fi
            fi
            EOF
          '';

          # Container environment package (for nix profile install compatibility)
          codebot-env = pkgs.buildEnv {
            name = "codebot-environment";
            paths = (mkBaseDeps { inherit pkgs system; }) ++ everythingExtra;
          };

          # (no container image is built via Nix on macOS; we use Dockerfile with Apple 'container')
        };
      }) //
    
    # NixOS configurations for proper container system setup
    {
      nixosConfigurations.codebot-container = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ({ pkgs, ... }: {
            boot.isContainer = true;
            
            # Allow unfree packages
            nixpkgs.config.allowUnfree = true;
            
            # Import our package set as system packages
            environment.systemPackages = let
              pkgs = nixpkgs.legacyPackages.aarch64-linux;
            in (mkBaseDeps { inherit pkgs; system = "aarch64-linux"; }) ++ 
               (mkEverythingExtra { inherit pkgs; system = "aarch64-linux"; });
            
            # Create /etc/profile.d script for Claude setup
            environment.etc."profile.d/codebot-init.sh" = {
              text = ''
                # Claude Code environment initialization
                if [ "$CODEBOT_INITIALIZED" != "1" ]; then
                  export CODEBOT_INITIALIZED=1
                  
                  # Set up Claude config files if they exist in workspace
                  if [ -f "/workspace/claude.json" ]; then
                    ln -sf /workspace/claude.json /root/.claude.json
                  fi
                  
                  if [ -d "/workspace/claude" ]; then
                    ln -sf /workspace/claude /root/.claude
                  fi
                  
                  # Change to workspace directory
                  if [ -d "/workspace" ]; then
                    cd /workspace
                  fi
                fi
              '';
              mode = "0644";
            };
            
            # Disable unnecessary services for containers
            services.udisks2.enable = false;
            security.polkit.enable = false;
            documentation.nixos.enable = false;
            programs.command-not-found.enable = false;
          })
        ];
      };
    };
}
