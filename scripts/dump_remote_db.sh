#!/bin/bash

export DB_USER=$1
export DB_PASS=$2
export ENTITY_NAME=$3
export ENTITY_ID=$4
export DB_HOST=$5
export DB_NAME=$6

if [ -z $ENTITY_NAME ] || [ -z $ENTITY_ID ] || [ -z $DB_USER ] || [ -z $DB_HOST ] || [ -z $DB_NAME ]; then
	echo "[ERROR] Expected 6 params: correct usage --> sudo ./dump_database.sh <DB_USER> <DB_PASS> <ENTITY_NAME> <ENTITY_ID> <DB_HOST> <DB_NAME>"
	exit -1
fi

#read -sp "Enter the database password: " DB_PASS

export BACKUP_DIR=./dumps/$ENTITY_ID
mkdir -p $BACKUP_DIR

declare -A table_conditions
while IFS="=" read -r key value; do
    table_conditions["$key"]="$value"
done < <(jq -r "to_entries | map(\"\(.key)=\(.value|tostring)\")|.[]" table_conditions.json)

# Function to create the backup for a table
function create_backup() {
    local TABLENAME="$1"
    local WHERE_CONDITION="$2"

    # Replace the $ENTITY_ID placeholder with the actual value in the WHERE_CONDITION
    WHERE_CONDITION=${WHERE_CONDITION//\$ENTITY_ID/$ENTITY_ID}

    if [[ -n "$WHERE_CONDITION" ]]; then
    	mysqldump -p$DB_PASS --host="$DB_HOST" -u"$DB_USER" --skip-column-statistics --skip-lock-tables --no-tablespaces "$DB_NAME" "$TABLENAME" --where="${WHERE_CONDITION}" | gzip > "$BACKUP_DIR/${TABLENAME}-${ENTITY_NAME}-${ENTITY_ID}.sql.gz"
    else
    	mysqldump -p$DB_PASS --host="$DB_HOST" -u"$DB_USER" --skip-column-statistics --skip-lock-tables --no-tablespaces "$DB_NAME" "$TABLENAME" | gzip > "$BACKUP_DIR/${TABLENAME}-${ENTITY_NAME}-${ENTITY_ID}.sql.gz"
    fi

}

echo "Backuping tables..."

# Loop through the associative array, extract the table name and the WHERE condition, and create backups accordingly
for TABLENAME in "${!table_conditions[@]}"
do
    WHERE_CONDITION="${table_conditions[$TABLENAME]}"
    create_backup "$TABLENAME" "$WHERE_CONDITION"
done

cd $BACKUP_DIR
cd ..

tar -czvf $ENTITY_NAME_$ENTITY_ID.tar $ENTITY_ID/

rm -R ./$ENTITY_ID

echo "¡Backup completed!"
