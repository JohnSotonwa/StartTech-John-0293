#!/bin/bash
set -e

# Deploy React frontend to S3 and invalidate CloudFront cache

echo "Syncing React build to S3 bucket: $S3_BUCKET_NAME..."
aws s3 sync frontend/dist s3://$S3_BUCKET_NAME --delete

echo "Invalidating CloudFront cache: $CLOUDFRONT_DIST_ID..."
aws cloudfront create-invalidation \
  --distribution-id $CLOUDFRONT_DIST_ID \
  --paths "/*"

echo "Frontend deployment complete!"
