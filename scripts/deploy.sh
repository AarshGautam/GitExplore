#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────
# Required Environment Variables
# ─────────────────────────────────────
: "${DOCKERHUB_USERNAME:?Missing}"
: "${DOCKERHUB_TOKEN:?Missing}"
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

    # ─────────────────────────────────
    # 1. Create network if it doesn't exist
    # ─────────────────────────────────
    NETWORK_NAME="todo-network"
    if ! docker network inspect "$NETWORK_NAME" > /dev/null 2>&1; then
        echo "🌐 Creating network: $NETWORK_NAME..."
        docker network create "$NETWORK_NAME"
    else
        echo "✅ Network $NETWORK_NAME already exists"
    fi

    # ─────────────────────────────────
    # 2. Login to Docker Hub
    # ─────────────────────────────────
    echo "🔐 Logging in to Docker Hub..."
    echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

    # ─────────────────────────────────
    # 3. Pull latest image
    # ─────────────────────────────────
    echo "📥 Pulling image: $DOCKERHUB_USERNAME/$IMAGE..."
    docker pull "$DOCKERHUB_USERNAME/$IMAGE"

    # ─────────────────────────────────
    # 4. Stop and remove old container
    # ─────────────────────────────────
    echo "🛑 Stopping old container (if exists)..."
    docker stop "$CONTAINER" 2>/dev/null || true
    docker rm "$CONTAINER" 2>/dev/null || true

    # ─────────────────────────────────
    # 5. Start new container
    # ─────────────────────────────────
    echo "▶️ Starting new container..."
    docker run -d \
        --name "$CONTAINER" \
        --network "$NETWORK_NAME" \
        --restart unless-stopped \
        -p "$PORT:$PORT" \
        "$DOCKERHUB_USERNAME/$IMAGE"

    # ─────────────────────────────────
    # 6. Cleanup old images
    # ─────────────────────────────────
    echo "🧹 Cleaning up old images..."
    docker image prune -f

    echo "✅ Container $CONTAINER is running on port $PORT"
EOF

# ─────────────────────────────────────
# Cleanup SSH key
# ─────────────────────────────────────
rm -f "$SSH_KEY_FILE"
echo "✅ Deployment complete!"