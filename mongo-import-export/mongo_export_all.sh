#!/bin/bash

# Check if we have the right amount of arguments
if [ "$#" -ne 2 ]; then
    echo "❌ Error: Missing arguments, locura."
    echo "👉 Usage: $0 <MONGO_URI> <PLACEHOLDER_NAME>"
    echo "💡 Example: $0 \"mongodb://user:pass@localhost:27017/my_database\" \"Production-Backup\""
    exit 1
fi

MONGO_URI="$1"
PLACEHOLDER_NAME="$2"

echo "🚀 Starting export job: $PLACEHOLDER_NAME"
echo "🔍 Analyzing database..."

# Extract the database name using mongosh
DB_NAME=$(mongosh "$MONGO_URI" --quiet --eval "db.getName()")

if [ $? -ne 0 ] || [ -z "$DB_NAME" ]; then
    echo "❌ Error: Could not connect to MongoDB or extract the database name. Check your URI!"
    exit 1
fi

# Create the export directory
EXPORT_DIR="${DB_NAME}-export"
mkdir -p "$EXPORT_DIR"
echo "📂 Created export directory: ./$EXPORT_DIR"

# Get all collections (tables) from the database
COLLECTIONS=$(mongosh "$MONGO_URI" --quiet --eval "db.getCollectionNames().join(' ')")

if [ -z "$COLLECTIONS" ]; then
    echo "⚠️ No collections found in database '$DB_NAME'. Nothing to do."
    exit 0
fi

# Iterate over each collection and export it
for COLLECTION in $COLLECTIONS; do
    # Skip system collections, we don't need those in a standard backup
    if [[ "$COLLECTION" == system.* ]]; then
        continue
    fi

    # Format: [db-table].json as requested
    OUT_FILE="${EXPORT_DIR}/[${DB_NAME}-${COLLECTION}].json"
    
    echo "📦 Exporting collection: $COLLECTION -> $OUT_FILE"
    
    # Run mongoexport
    mongoexport --uri="$MONGO_URI" --collection="$COLLECTION" --out="$OUT_FILE"
done

echo "✅ Fantastic, dude! Export complete. All your files are in ./$EXPORT_DIR"
