#!/bin/bash

ENTITY_NAME=$1
ENTITY_ID=$2
TABLE_CONDITIONS_PATH=$3
PATH_TO_SSH_KEY=$4
LOCAL_DB_NAME=$5
HOST=$6
DB_HOST=$7
DB_NAME=$8
DB_USER=$9
#DB_PASSWORD="${10}"

if [ -z $ENTITY_NAME ] || [ -z $ENTITY_ID ] || [ -z $TABLE_CONDITIONS_PATH ] || [ -z $PATH_TO_SSH_KEY ] || [ -z $LOCAL_DB_NAME ] || [ -z $HOST ] || [ -z $DB_HOST ] || [ -z $DB_NAME ] || [ -z $DB_USER ]; then
    echo "[ERROR] Expected 9 params: correct usage --> ./decompress_and_import_dump.sh <ENTITY_NAME> <ENTITY_ID> <TABLE_CONDITIONS_PATH> <PATH_TO_SSH_KEY> <LOCAL_DB_NAME> <HOST> <DB_HOST> <DB_NAME> <DB_USER>"
    exit -1
fi


if [ -z $DB_PASSWORD ]; then
    echo "You need to provide the password for accessing the database via the DB_PASSWORD env var"
    echo "Example: export DB_PASSWORD='<password>'"
    exit -1
fi

# Update dump_database.sh remotely
scp -i $PATH_TO_SSH_KEY ./dump_remote_db.sh $HOST:/home/ubuntu/

# Upload the JSON file with the tables and conditions to the remote pc
scp -i $PATH_TO_SSH_KEY $TABLE_CONDITIONS_PATH $HOST:/home/ubuntu/

# Execute the dump creation script remotely
#echo "Enter the database password: "
ssh -i $PATH_TO_SSH_KEY $HOST "sudo ./dump_remote_db.sh $DB_USER $DB_PASSWORD $ENTITY_NAME $ENTITY_ID $DB_HOST $DB_NAME"

# Copy the compressed folder with the dump to our local pc
scp -i $PATH_TO_SSH_KEY $HOST:/home/ubuntu/dumps/$ENTITY_NAME_$ENTITY_ID.tar dump_$ENTITY_NAME_$ENTITY_ID.tar

# Unzip the compressed folder
tar -xzvf dump_$ENTITY_NAME_$ENTITY_ID.tar

echo "Decompressing all files..."
echo "Importing dump..."

# Move to the folder that contains all the tables
cd ./$ENTITY_ID

# Function to decompress and import the .sql file
import_sql_file() {
    local file="$1"
    local sql_file="${file%.gz}"

    gunzip -c "$file" | mysql -u root --protocol=tcp $LOCAL_DB_NAME
}

# For each compressed table dump, we decompress and import to our local db
for gz_file in *.gz; do
    if [ -f "$gz_file" ]; then
        import_sql_file "$gz_file"
    fi
done

cd ..

# Once is imported, we remove the used files and folders
rm -R $ENTITY_ID/ dump_$ENTITY_NAME_$ENTITY_ID.tar

echo "Import completed!"