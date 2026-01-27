#!/bin/bash
# deploy-frontend.sh
# Deploy React frontend to S3 and invalidate CloudFront cache

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <S3_BUCKET_NAME> <CLOUDFRONT_DIST_ID>"
  exit 1
fi

S3_BUCKET=$1
CLOUDFRONT_DIST=$2

echo "Deploying frontend to S3 bucket: $S3_BUCKET"

# Sync build folder to S3
aws s3 sync frontend/build s3://$S3_BUCKET --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DIST --paths "/*"

echo "Frontend deployed successfully!"
