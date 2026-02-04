#!/usr/bin/env bash
# Runs weekly (Monday 00:20 UTC)

LOG_DIR="/mnt/nas/ais_data"
WEEKLY_DIR="$LOG_DIR/weekly_archives"
mkdir -p "$WEEKLY_DIR"

START_LAST_WEEK="$(date -u -d 'last week monday' +'%Y-%m-%d')"
START_THIS_WEEK="$(date -u -d 'monday' +'%Y-%m-%d')"
ISO_WEEK_LABEL="$(date -u -d "${START_LAST_WEEK}" +'%G-W%V')"
ZIPFILE="$WEEKLY_DIR/ais_week_${ISO_WEEK_LABEL}.zip"

cd "$LOG_DIR" || exit 1

# Find CSVs from last week
find . -maxdepth 1 -type f -name '*.csv' \
    -newermt "${START_LAST_WEEK} 00:00" ! -newermt "${START_THIS_WEEK} 00:00" \
    -print > /tmp/weekly_list.txt

if [ -s /tmp/weekly_list.txt ]; then
    zip -q "$ZIPFILE" -@ < /tmp/weekly_list.txt && xargs rm -f < /tmp/weekly_list.txt
fi
rm /tmp/weekly_list.txt
