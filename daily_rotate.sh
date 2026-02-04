#!/usr/bin/env bash
# Runs daily at 00:10 UTC

LOG_DIR="/mnt/nas/ais_data"
DAILY_DIR="$LOG_DIR/daily_archives"
mkdir -p "$DAILY_DIR"

YESTERDAY="$(date -u -d 'yesterday' +'%Y-%m-%d')"
ZIPFILE="$DAILY_DIR/ais_daily_${YESTERDAY}.zip"

cd "$LOG_DIR" || exit 1

# Zip files from yesterday
if ls "${YESTERDAY}"_*.csv 1> /dev/null 2>&1; then
    zip -q "$ZIPFILE" "${YESTERDAY}"_*.csv && rm -f "${YESTERDAY}"_*.csv
fi
