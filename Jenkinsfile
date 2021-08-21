pipeline {
    agent {
        kubernetes {
            label 'spring-petclinic' // all your pods will be named with this prefix, followed by a unique id
            idleMinutes 5 // how long the pod will live after no jobs have run on it
            yamlFile 'ci/build-pod.yaml' // path to the pod definition relative to the root of our project
            defaultContainer 'jnlp'
            // define a default container if more than a few stages use it, will default to jnlp container
        }
    }

    environment {
        APP_NAME = "spring-petclinic"
        REPO_URL = "git@github.com:ppringle/spring-petclinic.git"
    }

    stages {

        stage("Env Variables") {
            steps {
                sh "printenv"
            }
        }

        stage('Fetch from GitHub') {
            steps {
                dir("app") {
                    git(
                            poll: true,
                            changelog: true,
                            branch: "main",
                            credentialsId: "github-ppringle",
                            url: "${REPO_URL}"
                    )
                    sh 'git rev-parse HEAD > git-commit.txt'
                }
            }
        }

        stage('Create Image') {
            steps {
                container('k8s') {
                    sshagent(['github-ppringle']) {
                        sh '''#!/bin/sh -e
                        export GIT_COMMIT=$(cat app/git-commit.txt)
                        kp image list
                        kp secret list
                        kubectl get sa
                        kp image save ${APP_NAME} \
                            --git https://github.com/ppringle/spring-petclinic \
                            -t index.docker.io/ppringle/spring-petclinic \
                            --env BP_GRADLE_BUILD_ARGUMENTS='--no-daemon build' \
                            --git-revision ${GIT_COMMIT} -w
                        kp build logs ${APP_NAME} 
                    '''
                    }
                }
            }
        }

//
//        stage('Update Deployment Manifest') {
//            steps {
//                container('k8s') {
//                    dir("gitops") {
//                        git(
//                                poll: false,
//                                changelog: false,
//                                branch: "master",
//                                credentialsId: "git-jenkins",
//                                url: "git@github.com:ppringle/spring-petclinic-gitops.git"
//                        )
//                    }
//                    sshagent(['git-jenkins']) {
//                        sh '''#!/bin/sh -e
//
//                        kubectl get image ${APP_NAME} -o json | jq -r .status.latestImage >> containerversion.txt
//                        export CONTAINER_VERSION=$(cat containerversion.txt)
//                        cd gitops/app
//                        kustomize edit set image ${APP_NAME}=${CONTAINER_VERSION}
//                        git config --global user.name "jenkins CI"
//                        git config --global user.email "none@none.com"
//                        git add .
//                        git diff-index --quiet HEAD || git commit -m "update by ci"
//                        mkdir -p ~/.ssh
//                        ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
//                        git pull -r origin master
//                        git push --set-upstream origin master
//                        '''
//                    }
//                }
//            }
//        }
    }
}
