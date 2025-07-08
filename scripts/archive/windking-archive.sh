#!/usr/bin/env bash
export SHELL=/bin/bash
export HOME=/root
export PATH=/usr/local/bin:/usr/bin:/bin
export AWS_PROFILE=windking
export AWS_DEFAULT_PROFILE=windking
export AWS_REGION=ap-southeast-1

# 归档昨天的数据
DATE=${DATE:-$(date -d "yesterday" +%F)}
LOGFILE="/var/log/windking/archive.log"
CSV_PATH="/var/log/windking/trade-$DATE.csv"
S3_PATH="s3://kk-sss-2025/windking-archive/$DATE/trade-$DATE.csv"

echo "[$(date '+%F %T')] 开始归档，日期=$DATE" | tee -a "$LOGFILE"

if [ ! -f "$CSV_PATH" ]; then
  echo "[$(date '+%F %T')] ❌ 未找到交易日志 $CSV_PATH" | tee -a "$LOGFILE"
  exit 1
fi

for i in 1 2 3; do
  if aws s3 cp "$CSV_PATH" "$S3_PATH" --profile windking; then
    echo "[$(date '+%F %T')] ✅ S3 上传成功 $S3_PATH (尝试 $i 次)" | tee -a "$LOGFILE"
    break
  else
    echo "[$(date '+%F %T')] ⚠️ S3 上传失败 (尝试 $i 次)" | tee -a "$LOGFILE"; sleep 5
  fi
done

echo "[$(date '+%F %T')] 检查 S3 归档: $DATE" | tee -a "$LOGFILE"
echo "[$(date '+%F %T')] 归档脚本执行完毕" | tee -a "$LOGFILE"
