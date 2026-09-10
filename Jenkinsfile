pipeline {
  agent any

  environment {
    DOCKERHUB_NAMESPACE = credentials('dockerhub-username')
    DOCKERHUB_CREDS = credentials('dockerhub-creds')
    IMAGE_RESERVATION = "${DOCKERHUB_NAMESPACE}/flight-reservation-app"
    IMAGE_CHECKIN = "${DOCKERHUB_NAMESPACE}/flight-checkin-app"
    IMAGE_FRONTEND = "${DOCKERHUB_NAMESPACE}/flight-frontend"
    TAG = "${BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Backend Tests') {
      steps {
        dir('FlightReservationApplication') { sh 'chmod +x mvnw && ./mvnw clean verify' }
        dir('FlightCheckInApplication') { sh 'chmod +x mvnw && ./mvnw clean verify' }
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

    stage('SonarQube') {
      when { expression { return env.SONAR_HOST_URL?.trim() } }
      steps {
        withSonarQubeEnv('sonarqube') {
          withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
            dir('FlightReservationApplication') {
              sh './mvnw -DskipTests sonar:sonar -Dsonar.token=$SONAR_TOKEN -Dsonar.host.url=$SONAR_HOST_URL'
            }
          }
        }
      }
    }

    stage('Docker Build') {
      steps {
        sh 'docker build -t ${IMAGE_RESERVATION}:${TAG} -t ${IMAGE_RESERVATION}:latest FlightReservationApplication'
        sh 'docker build -t ${IMAGE_CHECKIN}:${TAG} -t ${IMAGE_CHECKIN}:latest FlightCheckInApplication'
        sh 'docker build --build-arg VITE_API_URL= --build-arg VITE_API_CHECKIN_URL= -t ${IMAGE_FRONTEND}:${TAG} -t ${IMAGE_FRONTEND}:latest frontend'
      }
    }

    stage('Trivy Scan') {
      steps {
        sh 'docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity HIGH,CRITICAL --exit-code 1 ${IMAGE_RESERVATION}:${TAG}'
        sh 'docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity HIGH,CRITICAL --exit-code 1 ${IMAGE_CHECKIN}:${TAG}'
        sh 'docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity HIGH,CRITICAL --exit-code 1 ${IMAGE_FRONTEND}:${TAG}'
      }
    }

    stage('Push Images') {
      steps {
        sh 'echo "$DOCKERHUB_CREDS_PSW" | docker login -u "$DOCKERHUB_CREDS_USR" --password-stdin'
        sh 'docker push ${IMAGE_RESERVATION}:${TAG}'
        sh 'docker push ${IMAGE_RESERVATION}:latest'
        sh 'docker push ${IMAGE_CHECKIN}:${TAG}'
        sh 'docker push ${IMAGE_CHECKIN}:latest'
        sh 'docker push ${IMAGE_FRONTEND}:${TAG}'
        sh 'docker push ${IMAGE_FRONTEND}:latest'
      }
    }

    stage('Update GitOps') {
      steps {
        sh '''
          set -e
          sed -i "s#DOCKERHUB_USERNAME/flight-reservation-app:latest#${IMAGE_RESERVATION}:${TAG}#" gitops/reservation-deployment.yaml
          sed -i "s#DOCKERHUB_USERNAME/flight-checkin-app:latest#${IMAGE_CHECKIN}:${TAG}#" gitops/checkin-deployment.yaml
          sed -i "s#DOCKERHUB_USERNAME/flight-frontend:latest#${IMAGE_FRONTEND}:${TAG}#" gitops/frontend-deployment.yaml
          git config user.name "jenkins"
          git config user.email "jenkins@local"
          git add gitops/
          git diff --cached --quiet || git commit -m "Update images to build ${TAG} [skip ci]"
          git push origin HEAD:main
        '''
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
