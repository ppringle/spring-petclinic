#!/usr/bin/env bash

kubectl delete secret pks-cicd
kubectl create secret generic pks-cicd  --from-file jenkins-tbs-sa -n jenkins
