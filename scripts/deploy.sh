#!/bin/bash
set -e

IMAGE_TAG=${1:-latest}
REGISTRY="ghcr.io"
IMAGE_NAME="manoj24112005/devops-project"
FULL_IMAGE="${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "=========================================="
echo " Deploying ${FULL_IMAGE}"
echo "=========================================="

echo "Starting Docker service if needed..."
sudo systemctl start docker || true

echo "Pulling latest image..."
sudo docker pull ${FULL_IMAGE}

echo "Stopping existing container if running..."
sudo docker stop devops-project || true
sudo docker rm devops-project || true

echo "Starting new container..."
sudo docker run -d \
  --name devops-project \
  -p 5000:5000 \
  ${FULL_IMAGE}

echo "Verifying deployment..."
sleep 3
sudo docker ps | grep devops-project

echo "Testing container health..."
curl -f http://localhost:5000/health

echo "Deployment completed successfully!"
