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

    stage('Backend Tests') {
      steps {
        dir('FlightReservationApplication') {
          sh 'chmod +x mvnw'
          sh './mvnw clean verify'
        }

        dir('FlightCheckInApplication') {
          sh 'chmod +x mvnw'
          sh './mvnw clean verify'
        }
      }
    }

    stage('Frontend Checks') {
      steps {
        dir('frontend') {
          sh 'npm ci'
          sh 'npm run lint'
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
              sh '''
                ./mvnw -DskipTests sonar:sonar \
                  -Dsonar.token="$SONAR_TOKEN" \
                  -Dsonar.host.url="$SONAR_HOST_URL"
              '''
            }
          }
        }
      }
    }

    stage('Docker Build') {
      steps {
        sh '''
          set -e

          docker build \
            -t ${DOCKERHUB_CREDS_USR}/flight-reservation-app:${TAG} \
            -t ${DOCKERHUB_CREDS_USR}/flight-reservation-app:latest \
            FlightReservationApplication

          docker build \
            -t ${DOCKERHUB_CREDS_USR}/flight-checkin-app:${TAG} \
            -t ${DOCKERHUB_CREDS_USR}/flight-checkin-app:latest \
            FlightCheckInApplication

          docker build \
            --build-arg VITE_API_URL= \
            --build-arg VITE_API_CHECKIN_URL= \
            -t ${DOCKERHUB_CREDS_USR}/flight-frontend:${TAG} \
            -t ${DOCKERHUB_CREDS_USR}/flight-frontend:latest \
            frontend
        '''
      }
    }

    stage('Trivy Scan') {
      steps {
        sh '''
          set -e

          docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy:latest \
            image \
            --severity HIGH,CRITICAL \
            --exit-code 1 \
            ${DOCKERHUB_CREDS_USR}/flight-reservation-app:${TAG}

          docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy:latest \
            image \
            --severity HIGH,CRITICAL \
            --exit-code 1 \
            ${DOCKERHUB_CREDS_USR}/flight-checkin-app:${TAG}

          docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy:latest \
            image \
            --severity HIGH,CRITICAL \
            --exit-code 1 \
            ${DOCKERHUB_CREDS_USR}/flight-frontend:${TAG}
        '''
      }
    }

    stage('Push Images') {
      steps {
        sh '''
          set -e

          echo "$DOCKERHUB_CREDS_PSW" | \
            docker login \
              --username "$DOCKERHUB_CREDS_USR" \
              --password-stdin

          docker push ${DOCKERHUB_CREDS_USR}/flight-reservation-app:${TAG}
          docker push ${DOCKERHUB_CREDS_USR}/flight-reservation-app:latest

          docker push ${DOCKERHUB_CREDS_USR}/flight-checkin-app:${TAG}
          docker push ${DOCKERHUB_CREDS_USR}/flight-checkin-app:latest

          docker push ${DOCKERHUB_CREDS_USR}/flight-frontend:${TAG}
          docker push ${DOCKERHUB_CREDS_USR}/flight-frontend:latest
        '''
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
          sh '''
            set -e

            sed -i \
              "s#DOCKERHUB_USERNAME/flight-reservation-app:latest#${DOCKERHUB_CREDS_USR}/flight-reservation-app:${TAG}#" \
              gitops/reservation-deployment.yaml

            sed -i \
              "s#DOCKERHUB_USERNAME/flight-checkin-app:latest#${DOCKERHUB_CREDS_USR}/flight-checkin-app:${TAG}#" \
              gitops/checkin-deployment.yaml

            sed -i \
              "s#DOCKERHUB_USERNAME/flight-frontend:latest#${DOCKERHUB_CREDS_USR}/flight-frontend:${TAG}#" \
              gitops/frontend-deployment.yaml

            git config user.name "jenkins"
            git config user.email "jenkins@local"

            git add gitops/

            git diff --cached --quiet || \
              git commit -m "Update images to build ${TAG} [skip ci]"

            git -c credential.helper='!f() { echo username="$GITHUB_USER"; echo password="$GITHUB_TOKEN"; }; f' \
              push origin HEAD:main
          '''
        }
      }
    }
  }

  post {
    always {
      sh 'docker logout || true'
      sh 'docker image prune -f || true'
    }
  }
}
