#!/bin/bash
set -euo pipefail

FULL_NAME="$DOCKERHUB_USERNAME/$IMAGE:latest"

# 1. Log in to Docker Hub
# (Using --password-stdin is more secure than passing it as an argument)
echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

# 2. Build the Docker image
# $CONTEXT should be './client' as defined in your YAML
docker build -t "$FULL_NAME" "$CONTEXT"

# 3. Push the image to Docker Hub
docker push "$FULL_NAME"

# 4. Log out
docker logout