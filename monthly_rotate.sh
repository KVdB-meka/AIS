#!/usr/bin/env bash
# Runs monthly (1st of month 00:30 UTC)

LOG_DIR="/mnt/nas/ais_data"
MONTHLY_DIR="$LOG_DIR/monthly_archives"
mkdir -p "$MONTHLY_DIR"

LAST_MONTH="$(date -u -d 'first day of last month' +'%Y-%m')"
ZIPFILE="$MONTHLY_DIR/ais_month_${LAST_MONTH}.zip"

cd "$LOG_DIR" || exit 1

# Find files older than 30 days
find . -maxdepth 1 -type f -name '*.csv' -mtime +30 -print > /tmp/monthly_list.txt

if [ -s /tmp/monthly_list.txt ]; then
    zip -q "$ZIPFILE" -@ < /tmp/monthly_list.txt && xargs rm -f < /tmp/monthly_list.txt
fi
rm /tmp/monthly_list.txt
