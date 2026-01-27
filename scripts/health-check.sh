#!/bin/bash
# health-check.sh
# Check backend API health endpoint

if [ -z "$1" ]; then
  echo "Usage: $0 <BACKEND_URL>"
  exit 1
fi

URL=$1

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL/health)

if [ "$HTTP_STATUS" -eq 200 ]; then
  echo "Backend is healthy ✅"
  exit 0
else
  echo "Backend is unhealthy ❌ (HTTP status: $HTTP_STATUS)"
  exit 1
fi
