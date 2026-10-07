#!/bin/bash
# Usage: deploy.sh <ec2-ip> <image-tag>
# Runs from Jenkins. Needs env: GHCR_USER, GHCR_TOKEN, GITHUB_REPO, SSH key at $SSH_KEY
# Rollback = run this same script with an OLDER tag.
set -e
IP=$1; TAG=$2
IMAGE="ghcr.io/${GHCR_USER}/${GITHUB_REPO}:${TAG}"
SSH="ssh -o StrictHostKeyChecking=accept-new -i ${SSH_KEY} ubuntu@${IP}"

echo "Waiting for SSH + Docker on ${IP}..."
for i in $(seq 1 30); do
  $SSH "docker --version" >/dev/null 2>&1 && break
  sleep 10
done
$SSH "docker --version"

# token is sent through stdin so it is not shown in logs
echo "${GHCR_TOKEN}" | $SSH "docker login ghcr.io -u ${GHCR_USER} --password-stdin"
$SSH "docker pull ${IMAGE}"
$SSH "docker rm -f app 2>/dev/null || true"
$SSH "docker run -d --name app --restart unless-stopped -p 5000:5000 ${IMAGE}"

echo "Health check..."
for i in $(seq 1 10); do
  if curl -fs "http://${IP}:5000/health"; then echo; echo "DEPLOYED ${IMAGE}"; exit 0; fi
  sleep 5
done
echo "Health check FAILED for ${IMAGE}"; exit 1
