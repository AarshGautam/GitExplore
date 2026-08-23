#!/bin/bash
set -euo pipefail
# --- settings (same image you pushed in Script 1) ---
USERNAME="rogaw"
IMAGE="todo-repo"
TAG="back"
FULL_NAME="$USERNAME/$IMAGE:$TAG"
CONTAINER="mern-server"
# --- connection details ---
KEY="newkey.pem"
EC2_HOST="ubuntu@54.237.12.21"
echo "Deploying $FULL_NAME to $EC2_HOST ..."
# run all the deploy commands ON the server, over SSH
ssh -o StrictHostKeyChecking=accept-new -i "$KEY" "$EC2_HOST" "
    docker pull $FULL_NAME
    docker stop $CONTAINER 2>/dev/null || true
    docker rm $CONTAINER 2>/dev/null || true
    docker run -d --name $CONTAINER \
        --restart always -p 4200:4200 $FULL_NAME
"
echo "Deployed. App is live on port 4200."