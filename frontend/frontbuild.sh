#!/bin/bash
set -euo pipefail 

echo "Building the MERN Todo application..."

USERNAME="rogaw"
IMAGENAME="mern-todo"
TAG="v1.0"

FUllNAME="$USERNAME/$IMAGENAME:$TAG"

# --- 1. build the image from the Dockerfile here ---
docker build -t "$FULLNAME" .
# --- 2. push it to Docker Hub ---
docker push "$FULLNAME"