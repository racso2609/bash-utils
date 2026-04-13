#!/bin/bash

# Check if we have the right amount of arguments
if [ "$#" -ne 2 ]; then
    echo "❌ Error: Missing arguments, locura."
    echo "👉 Usage: $0 <MONGO_URI> <EXPORT_FOLDER>"
    echo "💡 Example: $0 \"mongodb://user:pass@localhost:27017/new_database\" \"my_database-export\""
    exit 1
fi

MONGO_URI="$1"
EXPORT_FOLDER="$2"

# Check if the folder actually exists
if [ ! -d "$EXPORT_FOLDER" ]; then
    echo "❌ Error: Folder '$EXPORT_FOLDER' does not exist. Come on, check your paths!"
    exit 1
fi

echo "🚀 Starting import job..."

# We need to extract the original DB name from the folder name to parse the filenames correctly.
# The previous script created folders named <DB_NAME>-export
DIR_NAME=$(basename "$EXPORT_FOLDER")
OLD_DB=${DIR_NAME%-export}

# Get all JSON files in the directory
shopt -s nullglob
JSON_FILES=("$EXPORT_FOLDER"/*.json)

if [ ${#JSON_FILES[@]} -eq 0 ]; then
    echo "⚠️ No JSON files found in '$EXPORT_FOLDER'. Nothing to import, dude."
    exit 0
fi

echo "📂 Found ${#JSON_FILES[@]} files to import."

for FILE_PATH in "${JSON_FILES[@]}"; do
    FILENAME=$(basename "$FILE_PATH")
    
    # Extract collection name.
    # We know the format is [olddb-collection].json from the export script.
    PREFIX="[${OLD_DB}-"
    SUFFIX="].json"
    
    # Strip prefix and suffix safely using bash string manipulation
    TEMP_NAME=${FILENAME#"$PREFIX"}
    COLLECTION=${TEMP_NAME%"$SUFFIX"}

    # Fallback/Safety check: if the filename didn't match the expected pattern, skip it to avoid messing up the DB
    if [[ "$COLLECTION" == "$FILENAME" || -z "$COLLECTION" ]]; then
        echo "⚠️ Warning: File '$FILENAME' doesn't match the expected format [db-collection].json. Skipping."
        continue
    fi
    
    echo "📦 Importing into collection: $COLLECTION from $FILENAME"
    
    # Run mongoimport using upsert mode so it doesn't fail if documents already exist
    mongoimport --uri="$MONGO_URI" --collection="$COLLECTION" --file="$FILE_PATH" --mode=upsert
done

echo "✅ Fantastic! Import complete. Your database should be populated now."