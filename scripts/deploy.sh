#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────
# Required Environment Variables
# ─────────────────────────────────────
: "${DOCKERHUB_USERNAME:?Missing}"
: "${DOCKERHUB_TOKEN:?Missing}"        # ✅ Validate it exists
: "${IMAGE:?Missing}"
: "${CONTAINER:?Missing}"
: "${PORT:?Missing}"
: "${EC2_HOST:?Missing}"
: "${EC2_USER:?Missing}"
: "${EC2_SSH_KEY:?Missing}"

# ─────────────────────────────────────
# SSH Key Setup
# ─────────────────────────────────────
SSH_KEY_FILE=$(mktemp /tmp/ssh_key_XXXXXX)
echo "$EC2_SSH_KEY" > "$SSH_KEY_FILE"
chmod 600 "$SSH_KEY_FILE"

# ─────────────────────────────────────
# Deploy via SSH
# ─────────────────────────────────────
echo "🚀 Deploying $CONTAINER to EC2 ($EC2_HOST)..."

ssh -o StrictHostKeyChecking=no \
    -i "$SSH_KEY_FILE" \
    "$EC2_USER@$EC2_HOST" \
    DOCKERHUB_USERNAME="$DOCKERHUB_USERNAME" \
    DOCKERHUB_TOKEN="$DOCKERHUB_TOKEN" \
    IMAGE="$IMAGE" \
    CONTAINER="$CONTAINER" \
    PORT="$PORT" \
    bash -s << 'EOF'

    set -e

    echo "🔐 Logging in to Docker Hub..."
    echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

    echo "📥 Pulling image: $DOCKERHUB_USERNAME/$IMAGE..."
    docker pull "$DOCKERHUB_USERNAME/$IMAGE"

    echo "🛑 Stopping old container (if exists)..."
    docker stop "$CONTAINER" 2>/dev/null || true
    docker rm "$CONTAINER" 2>/dev/null || true

    echo "▶️ Starting new container..."
    docker run -d \
        --name "$CONTAINER" \
        --restart unless-stopped \
        -p "$PORT:$PORT" \
        "$DOCKERHUB_USERNAME/$IMAGE"

    echo "🧹 Cleaning up old images..."
    docker image prune -f

    echo "✅ Container $CONTAINER is running on port $PORT"
EOF

# ─────────────────────────────────────
# Cleanup
# ─────────────────────────────────────
rm -f "$SSH_KEY_FILE"
echo "✅ Deployment complete!"