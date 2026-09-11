pipeline {
  agent any

  environment {
    DOCKERHUB_CREDS = credentials('dockerhub-creds')
    TAG = "${BUILD_NUMBER}"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Backend Build') {
      steps {
        sh """
          set -e

          DB_CONTAINER="ci-mysql-${BUILD_NUMBER}"

          docker run -d \
            --name "\${DB_CONTAINER}" \
            -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
            -e MYSQL_DATABASE=flightdb \
            -p 3307:3306 \
            mysql:8.4

          for i in \$(seq 1 60); do
            if docker exec "\${DB_CONTAINER}" \
              mysqladmin ping -h 127.0.0.1 -uroot --silent; then
              break
            fi

            if [ "\$i" -eq 60 ]; then
              docker logs "\${DB_CONTAINER}" || true
              exit 1
            fi

            sleep 2
          done

          docker exec "\${DB_CONTAINER}" \
            mysql -uroot \
            -e "CREATE DATABASE IF NOT EXISTS checkin_db;"

          cd FlightReservationApplication

          mvn clean verify \
            -Dspring.datasource.url="jdbc:mysql://127.0.0.1:3307/flightdb?createDatabaseIfNotExist=true" \
            -Dspring.datasource.username=root \
            -Dspring.datasource.password=""

          cd ../FlightCheckInApplication

          mvn clean package -DskipTests
        """
      }
    }

    stage('Frontend Checks') {
      steps {
        dir('frontend') {
          sh 'npm ci'

          sh """
            set +e
            npm run lint
            LINT_STATUS=\$?

            if [ "\$LINT_STATUS" -ne 0 ]; then
              echo "WARNING: ESLint reported issues. Continuing."
            fi

            exit 0
          """

          sh 'VITE_API_URL= VITE_API_CHECKIN_URL= npm run build'
        }
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('SonarQube') {
          withCredentials([
            string(
              credentialsId: 'sonarqube-token',
              variable: 'SONAR_TOKEN'
            )
          ]) {
            dir('FlightReservationApplication') {
              sh """
                mvn -DskipTests sonar:sonar \
                  -Dsonar.token="\${SONAR_TOKEN}" \
                  -Dsonar.host.url="\${SONAR_HOST_URL}"
              """
            }
          }
        }
      }
    }

    stage('Docker Build') {
      steps {
        sh """
          set -e

          docker build \
            -t \${DOCKERHUB_CREDS_USR}/flight-reservation-app:\${TAG} \
            -t \${DOCKERHUB_CREDS_USR}/flight-reservation-app:latest \
            FlightReservationApplication

          docker build \
            -t \${DOCKERHUB_CREDS_USR}/flight-checkin-app:\${TAG} \
            -t \${DOCKERHUB_CREDS_USR}/flight-checkin-app:latest \
            FlightCheckInApplication

          docker build \
            --build-arg VITE_API_URL= \
            --build-arg VITE_API_CHECKIN_URL= \
            -t \${DOCKERHUB_CREDS_USR}/flight-frontend:\${TAG} \
            -t \${DOCKERHUB_CREDS_USR}/flight-frontend:latest \
            frontend
        """
      }
    }

    stage('Trivy Scan') {
      steps {
        sh """
          set -e

          docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy:latest \
            image \
            --severity HIGH,CRITICAL \
            --exit-code 1 \
            \${DOCKERHUB_CREDS_USR}/flight-reservation-app:\${TAG}

          docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy:latest \
            image \
            --severity HIGH,CRITICAL \
            --exit-code 1 \
            \${DOCKERHUB_CREDS_USR}/flight-checkin-app:\${TAG}

          docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy:latest \
            image \
            --severity HIGH,CRITICAL \
            --exit-code 1 \
            \${DOCKERHUB_CREDS_USR}/flight-frontend:\${TAG}
        """
      }
    }

    stage('Push Images') {
      steps {
        sh """
          set -e

          echo "\${DOCKERHUB_CREDS_PSW}" | \
            docker login \
              --username "\${DOCKERHUB_CREDS_USR}" \
              --password-stdin

          docker push \${DOCKERHUB_CREDS_USR}/flight-reservation-app:\${TAG}
          docker push \${DOCKERHUB_CREDS_USR}/flight-reservation-app:latest

          docker push \${DOCKERHUB_CREDS_USR}/flight-checkin-app:\${TAG}
          docker push \${DOCKERHUB_CREDS_USR}/flight-checkin-app:latest

          docker push \${DOCKERHUB_CREDS_USR}/flight-frontend:\${TAG}
          docker push \${DOCKERHUB_CREDS_USR}/flight-frontend:latest
        """
      }
    }

    stage('Update GitOps') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'github',
            usernameVariable: 'GITHUB_USER',
            passwordVariable: 'GITHUB_TOKEN'
          )
        ]) {
          sh """
            set -e

            sed -i -E \
              "s|^([[:space:]]*image:)[[:space:]].*flight-reservation-app.*|\\\\1 \${DOCKERHUB_CREDS_USR}/flight-reservation-app:\${TAG}|" \
              gitops/reservation-deployment.yaml

            sed -i -E \
              "s|^([[:space:]]*image:)[[:space:]].*flight-checkin-app.*|\\\\1 \${DOCKERHUB_CREDS_USR}/flight-checkin-app:\${TAG}|" \
              gitops/checkin-deployment.yaml

            sed -i -E \
              "s|^([[:space:]]*image:)[[:space:]].*flight-frontend.*|\\\\1 \${DOCKERHUB_CREDS_USR}/flight-frontend:\${TAG}|" \
              gitops/frontend-deployment.yaml

            git config user.name "jenkins"
            git config user.email "jenkins@local"

            git add gitops/

            if ! git diff --cached --quiet; then
              git commit -m "Update images to build \${TAG} [skip ci]"

              git -c credential.helper='!f() { echo username="\$GITHUB_USER"; echo password="\$GITHUB_TOKEN"; }; f' \
                push origin HEAD:main
            else
              echo "No GitOps changes required"
            fi
          """
        }
      }
    }
  }

  post {
    always {
      sh """
        docker logout || true
        docker rm -f ci-mysql-\${BUILD_NUMBER} 2>/dev/null || true
        docker image prune -f || true
      """
    }
  }
}
