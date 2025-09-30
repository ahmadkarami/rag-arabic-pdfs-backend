#!/bin/bash

# Settings
CONTAINER_NAME=dev_postgres
DB_NAME=postgres      # destination DB name
DB_USER=postgres      # destination DB user
BACKUP_FILE=$1        # first argument = path to backup file

if [ -z "$BACKUP_FILE" ]; then
  echo "Please provide a backup file to restore"
  echo "Usage: ./restore.sh backup_YYYYMMDD_HHMMSS.sql"
  exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Backup file $BACKUP_FILE does not exist"
  exit 1
fi

echo "⚡ Restoring $BACKUP_FILE into $DB_NAME..."
cat "$BACKUP_FILE" | docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME

echo "✅ Restore complete"