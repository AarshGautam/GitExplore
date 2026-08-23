#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────
# Required Environment Variables
# ─────────────────────────────────────
# DOCKERHUB_USERNAME  - Docker Hub username
# DOCKERHUB_TOKEN     - Docker Hub access token
# IMAGE               - Image name with tag (e.g., todo-repo:front)
# CONTEXT             - Build context path (e.g., ./app/client)

echo "========================================="
echo "  Building & Pushing: $IMAGE"
echo "========================================="

# 1. Validate required variables
: "${DOCKERHUB_USERNAME:?Missing DOCKERHUB_USERNAME}"
: "${DOCKERHUB_TOKEN:?Missing DOCKERHUB_TOKEN}"
: "${IMAGE:?Missing IMAGE}"
: "${CONTEXT:?Missing CONTEXT}"

# 2. Log in to Docker Hub
echo "🔐 Logging in to Docker Hub..."
echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

# 3. Build the image
FULL_IMAGE_NAME="$DOCKERHUB_USERNAME/$IMAGE"
echo "🔨 Building: $FULL_IMAGE_NAME from $CONTEXT..."
docker build -t "$FULL_IMAGE_NAME" "$CONTEXT"

# 4. Push the image
echo "📤 Pushing: $FULL_IMAGE_NAME..."
docker push "$FULL_IMAGE_NAME"

# 5. Log out
echo "🔓 Logging out of Docker Hub..."
docker logout

echo "✅ Successfully built and pushed: $FULL_IMAGE_NAME"