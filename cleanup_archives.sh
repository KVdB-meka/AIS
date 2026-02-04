#!/usr/bin/env bash

## cleanup_archives.sh
# --------------------
# Runs periodically to remove old archives and save disk space.
# Retention Policy:
# - Daily Zips:  Keep for 30 days
# - Weekly Zips: Keep for 90 days (approx 3 months)
# - Monthly Zips: Keep forever

# 1) Configuration
LOG_DIR="/mnt/nas/ais_data"
DAILY_DIR="$LOG_DIR/daily_archives"
WEEKLY_DIR="$LOG_DIR/weekly_archives"

echo "Starting cleanup process..."

# 2) Clean Daily Archives (Older than 30 days)
if [ -d "$DAILY_DIR" ]; then
    echo "Cleaning Daily archives older than 30 days..."
    # Find files ending in .zip, modified more than 30 days ago, print them, and delete them
    find "$DAILY_DIR" -name "*.zip" -mtime +30 -print -delete
else
    echo "Daily archive directory not found."
fi

# 3) Clean Weekly Archives (Older than 90 days)
if [ -d "$WEEKLY_DIR" ]; then
    echo "Cleaning Weekly archives older than 90 days..."
    find "$WEEKLY_DIR" -name "*.zip" -mtime +90 -print -delete
else
    echo "Weekly archive directory not found."
fi

echo "Cleanup complete."
