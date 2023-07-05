#!/usr/bin/env bash

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 428855609275.dkr.ecr.us-east-1.amazonaws.com/toluna-lab

docker image build -t 428855609275.dkr.ecr.us-east-1.amazonaws.com/toluna-lab:latest .
docker push 428855609275.dkr.ecr.us-east-1.amazonaws.com/toluna-lab:latest