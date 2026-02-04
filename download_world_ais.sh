#!/usr/bin/env bash

# Configuration
API_KEY="YOUR_AISHUB_API_KEY"
LOG_DIR="/mnt/nas/ais_data"
DB_PATH="$LOG_DIR/ais.sqlite"
TS="$(date -u +'%Y-%m-%d_%H%M')"
OUTFILE="${LOG_DIR}/${TS}.csv"
URL="http://data.aishub.net/ws.php?username=${API_KEY}&format=1&output=csv&compress=0&latmin=-90&latmax=90&lonmin=-180&lonmax=180"

# 1. Download CSV
curl -s -m 60 -f "$URL" -o "$OUTFILE" || exit 1

# 2. Append to Master CSV (skipping header)
if [ ! -f "$LOG_DIR/master.csv" ]; then
    head -n 1 "$OUTFILE" > "$LOG_DIR/master.csv"
fi
tail -n +2 "$OUTFILE" >> "$LOG_DIR/master.csv"

# 3. Insert into SQLite (Expanding Database)
sqlite3 "$DB_PATH" <<EOF
CREATE TABLE IF NOT EXISTS ais (
  mmsi INTEGER, time_utc TEXT, longitude REAL, latitude REAL, 
  sog REAL, cog REAL, name TEXT, 
  PRIMARY KEY (mmsi, time_utc)
);
.mode csv
.import "$OUTFILE" ais_temp
INSERT OR IGNORE INTO ais SELECT * FROM ais_temp;
DROP TABLE ais_temp;
EOF
