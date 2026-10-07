# DevOps Cloud CI/CD Automated Deployment Project

A complete, beginner-friendly Cloud & DevOps CI/CD pipeline built on Windows, automating application testing, containerization, image registry publishing, infrastructure provisioning, and remote container deployment.

---

## 1. Primary Goal & Architecture Workflow

This project adheres strictly to the exact instructor workflow:

```text
Terraform HCL
      ↓
     Git
      ↓
    GitHub
      ↓
   Jenkins (Automation)
      ↓
 ┌────┴────────┐
 ↓             ↓
Job 1        Job 2
 ↓             ↓
Docker       Terraform
Image        EC2
 ↓             ↓
GHCR        AWS EC2 (eu-north-1)
               ↓
          Install Docker
               ↓
          Pull GHCR image
               ↓
            Docker run
               ↓
           Container (Port 5000)
```

---

## 2. Technology Stack

- **Application Stack**: Python 3.12, Flask, Pytest
- **Containerization**: Docker, Docker Desktop (WSL2 Engine)
- **Container Registry**: GitHub Container Registry (GHCR) `ghcr.io`
- **Source Control**: Git, GitHub
- **Automation Server**: Jenkins (Port 8080)
- **Infrastructure as Code**: Terraform (AWS Provider `~> 5.0`)
- **Cloud Provider**: AWS (`eu-north-1` Region, EC2 `t3.micro`)

---

## 3. Project Directory Structure

```text
devops-project/
├── app/
│   ├── app.py
│   └── requirements.txt
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── scripts/
│   └── deploy.sh
├── tests/
│   └── test_app.py
├── Dockerfile
├── .dockerignore
├── .gitignore
├── Jenkinsfile.job1
├── Jenkinsfile.job2
└── README.md
```

---

## 4. Prerequisites & Environment Setup

- **Windows PC** with PowerShell & VS Code
- **Git** (`git --version`)
- **Docker Desktop** (`docker --version`) - running with WSL2 engine
- **Terraform** (`terraform version`)
- **AWS CLI** (`aws --version`) configured for AWS Skill Builder (`eu-north-1`)
- **Jenkins Server** running locally on `http://localhost:8080`

---

## 5. Local Setup & Testing

### Phase 1: Local Application Testing
Install requirements and execute unit tests:
```powershell
python -m pip install -r app/requirements.txt
python -m pytest tests/
```

### Phase 2: Local Docker Verification
Build and test the container locally:
```powershell
docker build -t devops-project:v1 .
docker run -d -p 5000:5000 --name devops-project devops-project:v1
Invoke-RestMethod -Uri "http://localhost:5000/health"
docker stop devops-project
docker rm devops-project
```
Expected health endpoint response:
```json
{
  "status": "ok",
  "version": "dev"
}
```

---

## 6. GitHub Container Registry (GHCR) Setup

1. Generate a GitHub Personal Access Token (PAT) with `read:packages` and `write:packages` permissions on GitHub (Settings -> Developer Settings -> Personal Access Tokens).
2. Authenticate to GHCR locally or via Jenkins:
   ```powershell
   echo <YOUR_GITHUB_PAT> | docker login ghcr.io -u manoj24112005 --password-stdin
   ```

---

## 7. AWS Infrastructure Setup (Terraform)

Infrastructure is managed under `terraform/` configured for region `eu-north-1`.

1. Navigate to terraform directory:
   ```powershell
   cd terraform
   ```
2. Initialize and validate Terraform configuration:
   ```powershell
   terraform init
   terraform validate
   ```
3. Plan infrastructure creation:
   ```powershell
   terraform plan
   ```
4. Apply infrastructure (creates Security Group and EC2 Instance in default VPC):
   ```powershell
   terraform apply -auto-approve
   ```

---

## 8. Jenkins Automation Setup

### Required Credentials in Jenkins (Manage Jenkins -> Credentials)

1. **GHCR Credentials** (`Username with password`):
   - **ID**: `ghcr-token`
   - **Username**: `manoj24112005`
   - **Password**: GitHub Personal Access Token (PAT)

2. **AWS Credentials**:
   - Environment variables or AWS credentials file configured on the Jenkins worker host.

3. **EC2 Private Key** (`SSH Username with private key` or `Secret file`):
   - **ID**: `ec2-ssh-key`
   - **Private Key**: Contents of `.pem` key pair used for AWS EC2 instance.

---

### Jenkins Job 1: `devops-project-job1` (CI + Docker + GHCR)
- **Pipeline Source**: Pipeline script from SCM (Git)
- **Repository URL**: `https://github.com/manoj24112005/devops-project.git`
- **Script Path**: `Jenkinsfile.job1`
- **Flow**: Checkout -> Run Pytest -> Build Docker Image -> Tag Image (`v<BUILD_NUMBER>-<HASH>`) -> Login to GHCR -> Push Image to GHCR -> Trigger Job 2.

---

### Jenkins Job 2: `devops-project-job2` (Terraform + EC2 Deploy)
- **Pipeline Source**: Pipeline script from SCM (Git)
- **Repository URL**: `https://github.com/manoj24112005/devops-project.git`
- **Script Path**: `Jenkinsfile.job2`
- **Parameters**: `IMAGE_TAG` (string parameter)
- **Flow**: Checkout -> Terraform Apply (provisions EC2 in `eu-north-1`) -> Fetch EC2 Public IP -> SSH to EC2 -> Install/verify Docker -> Login GHCR -> Pull exact `IMAGE_TAG` -> Stop old container -> Run new container on port 5000 -> Verify `/health` endpoint.

---

## 9. GitHub Webhook Integration

1. Go to your GitHub repository: `https://github.com/manoj24112005/devops-project/settings/hooks`
2. Add Webhook:
   - **Payload URL**: `http://<YOUR_JENKINS_HOST>:8080/github-webhook/`
   - **Content type**: `application/json`
   - **Trigger events**: Push events
3. Saving triggers automatic build execution of `devops-project-job1` upon git push to `main`.

---

## 10. Rollback Procedure

If a new build fails or introduces a bug, perform manual rollback:

1. Open **Jenkins** -> `devops-project-job2`.
2. Click **Build with Parameters**.
3. Specify an earlier successful `IMAGE_TAG` (e.g., `v1-a1b2c3d`).
4. Click **Build**. Job 2 will redeploy the specified stable container version to EC2 immediately.

---

## 11. Resource Cleanup Procedure

To avoid unnecessary AWS charges in the Skill Builder training environment, tear down resources using Terraform:

1. Open PowerShell in `terraform/` directory:
   ```powershell
   cd terraform
   terraform plan -destroy
   ```
2. Confirm the destroy plan, then execute:
   ```powershell
   terraform destroy -auto-approve
   ```

---

## 12. Instructor Demo Steps

1. Show GitHub repository: `https://github.com/manoj24112005/devops-project`
2. Show local code structure (`app/`, `Dockerfile`, `terraform/`, `Jenkinsfile.job1`, `Jenkinsfile.job2`).
3. Show Jenkins Dashboard with `devops-project-job1` and `devops-project-job2`.
4. Trigger `Job 1` (or push code change to GitHub).
5. Inspect Job 1 logs: pytest success -> Docker build -> GHCR push -> trigger Job 2.
6. Inspect Job 2 logs: Terraform init/plan/apply -> EC2 IP retrieval -> SSH connection -> Docker pull -> Container execution.
7. Open web browser to `http://<EC2_PUBLIC_IP>:5000/health` and show live JSON response.
