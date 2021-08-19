pipeline {
    agent {
        kubernetes {
            label 'spring-petclinic' // all your pods will be named with this prefix, followed by a unique id
            idleMinutes 5 // how long the pod will live after no jobs have run on it
            yamlFile 'ci/build-pod.yaml' // path to the pod definition relative to the root of our project
            defaultContainer 'jnlp' // define a default container if more than a few stages use it, will default to jnlp container
        }
    }

    environment {
        APP_NAME = "${env.APP_NAME}"
        REPO_NAME = "spring-petclinic"

    }

    stages {

        stage('Fetch from GitHub') {
            steps {
                dir("app") {
                    git(
                            poll: true,
                            changelog: true,
                            branch: "main",
                            credentialsId: "github-ppringle",
                            url: "git@github.com:ppringle/${REPO_NAME}.git"
                    )
                    sh 'git rev-parse HEAD > git-commit.txt'
                }
            }
        }

        stage('Create Image') {
            steps {
                container('k8s') {
                    sh '''#!/bin/sh -e
                        export GIT_COMMIT=$(cat app/git-commit.txt)
                        kubectl config set-context jenkins-tbs-cluster
//
//                        kubectl config current-context
//                        kubectl get po
                    '''
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
