#!/bin/bash

kubectl apply -f rbac-tiller.yaml

helm init --service-account tiller
