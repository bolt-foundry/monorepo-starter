Infra

Purpose
- Infrastructure-as-code, delivery pipelines, and environment overlays.

Conventions
- IaC lives here (Terraform/Pulumi), along with Helm/K8s manifests if used.
- CI/CD config (e.g., GitHub Actions) and env overlays are organized by stage.
- Operational steps should link to `runbooks/`.

Suggested layout
- `envs/` — `dev/`, `stage/`, `prod/` overlays and variables
- `iac/` — Terraform/Pulumi projects
- `pipelines/` — CI/CD workflows and templates
