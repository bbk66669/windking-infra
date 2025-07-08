#!/usr/bin/env bash
set -e

# 本地脚本，每天归档“昨天整天”的交易日志
YESTERDAY=$(date -d "yesterday" +%F)
CSV_PATH="/var/log/windking/trade-$YESTERDAY.csv"

# 1. 让 Weaviate 容器内导出“昨天”的 TradeLog
docker exec infra-weaviate-1 sh -c "DATE='$YESTERDAY' sh /export_tradelog_csv.sh"

# 2. 把昨天的 CSV 从容器复制出来
docker cp infra-weaviate-1:/var/log/windking/trade-$YESTERDAY.csv /var/log/windking/

# 3. 简单校验
if [ ! -s "/var/log/windking/trade-$YESTERDAY.csv" ]; then
    echo "[ERROR] 日志归档 CSV 为空或不存在，需排查"
    exit 1
fi

echo "[OK] 导出并同步 TradeLog 成功：/var/log/windking/trade-$YESTERDAY.csv"
head -n 5 /var/log/windking/trade-$YESTERDAY.csv

# 4. 这里可以自动接着归档上传（如你需要一键全流程，可取消注释）
# bash /root/windking-archive.sh
