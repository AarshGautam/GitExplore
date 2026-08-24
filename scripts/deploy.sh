#!/bin/bash
set -euo pipefail

FULL_NAME="$DOCKERHUB_USERNAME/$IMAGE:latest"

echo "$EC2_SSH_KEY" > newkey.pem
chmod 400 newkey.pem

ssh -o StrictHostKeyChecking=accept-new -i newkey.pem \
  "$EC2_USER@$EC2_HOST" "
  docker pull $FULL_NAME
  docker stop $CONTAINER 2>/dev/null || true
  docker rm $CONTAINER 2>/dev/null || true

  docker run -d \
    --name $CONTAINER \
    --restart always \
    -p $PORT:$PORT \
    $EXTRA_DOCKER_ARGS \
    $FULL_NAME
"

rm -f newkey.pem