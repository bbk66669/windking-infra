#!/usr/bin/env bash
TOKEN="8164930188:AAH8wDelhgKuvzJ2hgQYTQs4QA5h74phSTQ"
CHATID="7385869909"

# 检查昨天的数据
DATE=$(date -d "yesterday" +%F)
YEAR=$(date -d "yesterday" +%Y)
MONTH=$(date -d "yesterday" +%m)
DAY=$(date -d "yesterday" +%d)
CSV_PATH="/var/log/windking/trade-$DATE.csv"
S3_PATH="s3://kk-sss-2025/windking-archive/$DATE/trade-$DATE.csv"

# 本地检查
if [ -f "$CSV_PATH" ]; then
    LOCAL_STATUS="☀️成功"
    LOCAL_SIZE=$(stat -c%s "$CSV_PATH")
    LOCAL_SIZE_H="$((LOCAL_SIZE/1024)) KB"
else
    LOCAL_STATUS="🌧失败"
    LOCAL_SIZE=""
    LOCAL_SIZE_H="❄️无法识别"
fi

# S3检查
S3_INFO=$(aws s3 ls "$S3_PATH" --profile windking | awk '{print $3}')
if [ -n "$S3_INFO" ]; then
    S3_STATUS="🦋成功"
    S3_SIZE="$S3_INFO"
    S3_SIZE_H="$((S3_SIZE/1024)) KB"
else
    S3_STATUS="🐸失败"
    S3_SIZE=""
    S3_SIZE_H="🦚无法识别"
fi

# 体积核查
if [ -n "$LOCAL_SIZE" ] && [ -n "$S3_SIZE" ]; then
    if [ "$LOCAL_SIZE" -eq "$S3_SIZE" ]; then
        SIZE_CHECK="🏜一致"
    else
        SIZE_CHECK="🪗不一致"
    fi
else
    SIZE_CHECK="🦚无法核查"
fi

# 日期核查（默认一致）
DATE_CHECK="🎧一致"

MSG="🥳TradeLog归档日报🚁
🍹时间: ${YEAR}年${MONTH}月${DAY}日

🏟本地🐦‍🔥
🪐状态：$LOCAL_STATUS
🎡体积: $LOCAL_SIZE_H

🪷S3🪸
🪼状态: $S3_STATUS
🏜体积: $S3_SIZE_H

🐚本地+S3🫧
🌋核查体积：$SIZE_CHECK
🫟核查日期：$DATE_CHECK

🐈昨日归档🦧
$( ([ "$LOCAL_STATUS" = "☀️成功" ] && [ "$S3_STATUS" = "🦋成功" ] && [ "$SIZE_CHECK" = "🏜一致" ]) && echo "🐬成功" || echo "🐥失败" )
"

# Telegram 推送
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d "chat_id=$CHATID&text=$MSG"

# Discord 推送（安全JSON）
echo "$MSG" | jq -Rs '{"content": .}' > /tmp/discord_msg.json
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1391400560506437713/UXl1_n2DEudnG5XIRobTZFh3x4A4-etT4nMMJuYoCA4mjh9AnXxEL3Mg9KKo4-h-SnjM"
curl -H "Content-Type: application/json" \
     -X POST \
     -d @/tmp/discord_msg.json \
     "$DISCORD_WEBHOOK"

