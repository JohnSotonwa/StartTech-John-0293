#!/bin/bash
# deploy-backend.sh
# Rolling update for backend EC2 instances

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <ALB_DNS_NAME> <ECR_REPO>"
  exit 1
fi

ALB_DNS=$1
ECR_REPO=$2
SSH_USER="ubuntu"        # Update if different
KEY_PATH="~/.ssh/starttech.pem"  # Update with your key path

# Fetch all backend instances from the ALB
INSTANCE_IDS=$(aws elbv2 describe-target-health \
    --target-group-arn $(aws elbv2 describe-target-groups --names backend-tg --query 'TargetGroups[0].TargetGroupArn' --output text) \
    --query 'TargetHealthDescriptions[*].Target.Id' --output text)

echo "Updating backend instances: $INSTANCE_IDS"

for INSTANCE in $INSTANCE_IDS; do
  echo "Deploying to instance: $INSTANCE"
  
  # SSH into the instance and pull the latest Docker image
  ssh -o StrictHostKeyChecking=no -i $KEY_PATH $SSH_USER@$INSTANCE <<EOF
    docker pull $ECR_REPO:latest
    docker stop backend || true
    docker rm backend || true
    docker run -d --name backend -p 8080:8080 --restart unless-stopped $ECR_REPO:latest
EOF

  echo "Deployment finished on instance: $INSTANCE"
done

echo "Backend deployed successfully!"
