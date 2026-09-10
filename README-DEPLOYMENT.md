# Flight Reservation Application - Complete Azure/AKS DevOps Package

This package preserves the application source/UI and adds the complete container, Jenkins, GitOps, MariaDB, and Argo CD deployment layer.

## Application components

- `frontend/`: existing React/Vite UI. No UI source files were changed.
- `FlightReservationApplication/`: existing Spring Boot reservation backend.
- `FlightCheckInApplication/`: existing Spring Boot check-in backend.
- `gitops/`: Kubernetes manifests for MariaDB, reservation backend, check-in backend, and frontend.
- `argocd-application.yaml`: Argo CD Application template.
- `Jenkinsfile`: CI pipeline for Maven tests, frontend checks, SonarQube (when configured), Docker build, Trivy scan, Docker Hub push, and GitOps image update.

## Runtime routing

The frontend is served by Nginx on port 80. Nginx keeps the browser talking to the same origin and routes:

- `/api/checkin/*` -> `flight-checkin-service:8081`
- `/api/*` -> `flight-reservation-service:8080`
- everything else -> React static files

This avoids changing the existing frontend API code or UI.

## Required one-time values

1. Replace `CHANGE_ME_STRONG_PASSWORD` in `gitops/secret.yaml`.
2. Replace Docker Hub and GitHub placeholders using `scripts/prepare-gitops.sh`.
3. Create Jenkins credentials:
   - `dockerhub-creds` (username/password)
   - `dockerhub-username` (secret text containing Docker Hub username)
   - `sonar-token` (only if SonarQube is enabled)
4. Configure Jenkins GitHub credentials so it can push the GitOps image-tag commit back to `main`.

## Argo CD

Apply `argocd-application.yaml` after replacing the repository URL:

```bash
kubectl apply -f argocd-application.yaml
```

Verify:

```bash
argocd app get flight-reservation
argocd app sync flight-reservation
```

## First deployment

Before the first Argo sync, make sure Docker Hub contains these images:

- `<dockerhub-user>/flight-reservation-app`
- `<dockerhub-user>/flight-checkin-app`
- `<dockerhub-user>/flight-frontend`

The Jenkinsfile pushes both the immutable build number tag and `latest`, then updates the GitOps Deployment manifests with the immutable build tag. Argo CD detects the Git change and reconciles the cluster.

## Persistence

MariaDB uses `mariadb-pvc` so application data survives pod replacement. Two logical databases are created on first MariaDB initialization: `flightdb` and `checkin_db`.

## Safety

The application source, React components, CSS, assets, routes, and existing Spring Boot business logic were left intact. Only deployment/container/CI/CD configuration was added or separated.
