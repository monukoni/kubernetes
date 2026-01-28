# Learn Kubernetes Project

This project simulates a real-world Kubernetes learning environment, featuring a full-stack application deployed on AWS using Terraform and Helm.

## Features

- **Backend**: 
 A golang application using `gorilla/mux` ensuring high performance.
    - Exposes Prometheus metrics at `/metrics`.
    - Health check endpoint at `/healthz`.
    - REST API returning INFO (OS, Hostname, Time).
- **Frontend**: A static HTML/JS dashboard served via Nginx.
    - Fetches data from the backend API.
    - Displays real-time server information.
- **Infrastructure as Code (IaC)**:
    - **Terraform**: Manages AWS resources including ECR repositories and OIDC for GitHub Actions.
    - **Modular Structure**: Organized into `bootstrap`, `app`, and `ops` layers.
- **Kubernetes**:
    - Deployment via **Helm Charts**.
    - Includes charts for backend, frontend, load-balancer, and service intentions.
    - specialized `argocd` and `grafana` configurations.

## Project Structure

```
├── src/            # Application Source Code
│   ├── backend/    # Go Backend
│   └── frontend/   # Static HTML/JS Frontend
├── terraform/      # Infrastructure Configuration
│   ├── layers/     # Terraform State Layers (bootstrap, app, ops)
│   └── modules/    # Reusable Terraform Modules
├── helm/           # Helm Charts for Kubernetes deployment
└── argocd/         # ArgoCD Application Manifests
```

## Getting Started

### Prerequisites

- AWS Account
- Terraform
- Docker
- Kubernetes Cluster (EKS)

### Deployment

1. **Bootstrap Infrastructure**:
   Navigate to `terraform/layers/bootstrap` and apply terraform to create ECR repos.
   ```bash
   cd terraform/layers/bootstrap
   terraform init && terraform apply
   ```

2. **Build & Push Images**:
   Build Docker images for `src/backend` and `src/frontend` and push to the ECR repositories created above.

3. **Deploy App**:
   Use Helm to deploy the application charts to your cluster.