#!/bin/bash
set -e

# Ensure required environment variable
: "${ALB_DNS_NAME:?ALB_DNS_NAME not set}"

URL="http://$ALB_DNS_NAME:8080/health"
echo "Checking backend health at $URL ..."

STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

if [ "$STATUS_CODE" -eq 200 ]; then
    echo "✅ Backend is healthy (status code $STATUS_CODE)"
else
    echo "❌ Backend health check failed (status code $STATUS_CODE)"
    exit 1
fi
