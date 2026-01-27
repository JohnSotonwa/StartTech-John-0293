#!/bin/bash
set -e

# Ensure required environment variables are set
: "${AWS_REGION:?AWS_REGION not set}"
: "${ECR_REPO:?ECR_REPO not set}"
: "${ALB_DNS_NAME:?ALB_DNS_NAME not set}"
: "${SSH_PRIVATE_KEY:?SSH_PRIVATE_KEY not set}"

echo "Deploying backend Docker image to instances behind ALB: $ALB_DNS_NAME"

# Fetch instance IDs behind the ALB
INSTANCE_IDS=$(aws elbv2 describe-target-health \
    --target-group-arn $(aws elbv2 describe-target-groups --names "backend-tg" --query "TargetGroups[0].TargetGroupArn" --output text --region "$AWS_REGION") \
    --query "TargetHealthDescriptions[].Target.Id" \
    --output text \
    --region "$AWS_REGION")

if [ -z "$INSTANCE_IDS" ]; then
    echo "No backend instances found behind ALB $ALB_DNS_NAME"
    exit 1
fi

echo "Found instances: $INSTANCE_IDS"
echo "Deploying Docker image $ECR_REPO:latest to all instances via SSH"

for INSTANCE_ID in $INSTANCE_IDS; do
    # Get public IP
    PUBLIC_IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query "Reservations[0].Instances[0].PublicIpAddress" \
        --output text \
        --region "$AWS_REGION")

    echo "Deploying to instance $INSTANCE_ID at $PUBLIC_IP"

    ssh -o StrictHostKeyChecking=no -i <(echo "$SSH_PRIVATE_KEY") ec2-user@$PUBLIC_IP << EOF
      docker pull $ECR_REPO:latest
      docker stop starttech-backend || true
      docker rm starttech-backend || true
      docker run -d --name starttech-backend -p 8080:8080 $ECR_REPO:latest
EOF

done

echo "Deployment complete! Backend is now running on all instances."
