# Jenkins credentials

Create these credentials in Jenkins:

- `dockerhub-creds`: Username with password type.
- `dockerhub-username`: Secret text containing the Docker Hub username.
- `sonar-token`: Secret text containing the SonarQube token (only when SonarQube is configured).
- GitHub push credentials: configure the Jenkins SCM credential used by the job so the `git push` in the GitOps stage can update `main`.
