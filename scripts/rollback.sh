#!/bin/bash
# rollback.sh
# Rollback backend Docker container to previous tag

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <ALB_DNS_NAME> <PREVIOUS_IMAGE_TAG>"
  exit 1
fi

ALB_DNS=$1
PREV_IMAGE=$2
SSH_USER="ubuntu"
KEY_PATH="~/.ssh/starttech.pem"

INSTANCE_IDS=$(aws elbv2 describe-target-health \
    --target-group-arn $(aws elbv2 describe-target-groups --names backend-tg --query 'TargetGroups[0].TargetGroupArn' --output text) \
    --query 'TargetHealthDescriptions[*].Target.Id' --output text)

for INSTANCE in $INSTANCE_IDS; do
  echo "Rolling back instance: $INSTANCE"
  ssh -o StrictHostKeyChecking=no -i $KEY_PATH $SSH_USER@$INSTANCE <<EOF
    docker stop backend || true
    docker rm backend || true
    docker run -d --name backend -p 8080:8080 --restart unless-stopped $PREV_IMAGE
EOF
done

echo "Rollback complete!"
