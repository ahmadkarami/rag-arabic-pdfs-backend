#!/bin/bash

# Settings
CONTAINER_NAME=dev_postgres
DB_NAME=postgres          # change if your DB name is different
DB_USER=postgres          # change if you created a custom user
BACKUP_FILE="./backup_$(date +%Y%m%d_%H%M%S).sql"

# Run pg_dump inside the container and copy to project root
docker exec -t $CONTAINER_NAME pg_dump -U $DB_USER $DB_NAME > $BACKUP_FILE

echo "✅ Backup saved to $BACKUP_FILE"