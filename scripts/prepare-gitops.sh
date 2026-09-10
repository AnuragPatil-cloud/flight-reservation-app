#!/usr/bin/env bash
set -euo pipefail
: "${DOCKERHUB_USERNAME:?Set DOCKERHUB_USERNAME before running}"
: "${GITHUB_REPO_URL:?Set GITHUB_REPO_URL before running}"

sed -i "s/DOCKERHUB_USERNAME/${DOCKERHUB_USERNAME}/g" gitops/*.yaml
sed -i "s#https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPOSITORY.git#${GITHUB_REPO_URL}#" argocd-application.yaml

echo "GitOps placeholders updated. Review gitops/secret.yaml before committing."
