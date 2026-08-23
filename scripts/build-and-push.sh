#!/bin/bash
set -euo pipefail

# 1. Log in to Docker Hub securely
echo "Logging in to Docker Hub..."
echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

# 2. Build and Push FRONTEND (Tag: latest)
FRONTEND_FULL_NAME="$DOCKERHUB_USERNAME/$IMAGE:latest"

echo "Building Frontend: $FRONTEND_FULL_NAME from $CONTEXT..."
docker build -t "$FRONTEND_FULL_NAME" "$CONTEXT"

echo "Pushing Frontend to Docker Hub..."
docker push "$FRONTEND_FULL_NAME"


# 3. Build and Push BACKEND (Tag: v1)
BACKEND_FULL_NAME="$DOCKERHUB_USERNAME/$IMAGE:v1"


echo "Building Backend: $BACKEND_FULL_NAME from $BACKEND_CONTEXT..."
docker build -t "$BACKEND_FULL_NAME" "$BACKEND_CONTEXT"

echo "Pushing Backend to Docker Hub..."
docker push "$BACKEND_FULL_NAME"


# 4. Log out
echo "Logging out of Docker Hub..."
docker logout

echo "✅ Both images built and pushed successfully!"