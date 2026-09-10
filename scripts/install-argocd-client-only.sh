#!/usr/bin/env bash
set -euo pipefail
sudo apt-get update
sudo apt-get install -y curl jq ca-certificates
if ! command -v argocd >/dev/null 2>&1; then
  VERSION="$(curl -fsSL https://api.github.com/repos/argoproj/argo-cd/releases/latest | jq -r .tag_name)"
  curl -fsSL "https://github.com/argoproj/argo-cd/releases/download/${VERSION}/argocd-linux-amd64" -o /tmp/argocd
  sudo install -m 0755 /tmp/argocd /usr/local/bin/argocd
  rm -f /tmp/argocd
fi
argocd version --client
