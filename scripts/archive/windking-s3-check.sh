#!/usr/bin/env bash
export SHELL=/bin/bash
export HOME=/root
export PATH=/usr/local/bin:/usr/bin:/bin
export AWS_PROFILE=windking
export AWS_DEFAULT_PROFILE=windking
export AWS_REGION=ap-southeast-1

AWS_CMD=$(which aws)
S3_BUCKET="kk-sss-2025"
DATE=${DATE:-$(date -d "yesterday" +%F)}

# 检查昨天的 trade-$DATE.csv 是否存在
S3_FILE_SIZE=$(
  $AWS_CMD s3 ls s3://$S3_BUCKET/windking-archive/$DATE/trade-$DATE.csv --profile windking | awk '{print $3}'
)

if [ -z "$S3_FILE_SIZE" ]; then
  curl -s -X POST "https://api.telegram.org/bot8164930188:AAH8wDelhgKuvzJ2hgQYTQs4QA5h74phSTQ/sendMessage" \
       -d "chat_id=7385869909&text=【警告】S3归档包缺失！日期：$DATE"
fi
