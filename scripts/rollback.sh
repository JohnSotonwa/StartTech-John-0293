#!/bin/bash
set -e

# Rollback script for frontend & backend

echo "Rolling back frontend to previous S3 version..."
# S3 rollback assumes versioning is enabled
aws s3 sync s3://$S3_BUCKET_NAME s3://$S3_BUCKET_NAME --exact-timestamps --delete

echo "Rolling back backend Docker image..."
ssh -o StrictHostKeyChecking=no -i "$SSH_PRIVATE_KEY" ec2-user@$ALB_DNS_NAME << EOF
  # Stop current container
  docker stop starttech-backend || true
  docker rm starttech-backend || true

  # Pull previous image tag (assumes 'previous' tag exists)
  docker pull $ECR_REPO:previous
  docker run -d \
    --name starttech-backend \
    -p 8080:8080 \
    --env REDIS_ENDPOINT=$REDIS_ENDPOINT \
    --env MONGO_URI=$MONGO_URI \
    $ECR_REPO:previous
EOF

echo "Rollback complete!"
