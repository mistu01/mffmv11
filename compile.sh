#!/bin/bash

# Get first part of archive name  
read -p "Enter name: " NAME
MODIFIED_NAME="[MFFMv11] $NAME"

# Get date string
DATE=`date +%y%m%d` 

# Version string
VERSION=`date +%y.%m.%d`

# Update name and version values in module.prop
sed -i "s/\(name=\).*/\1$MODIFIED_NAME/" module.prop
sed -i "s/\(versionCode=\).*/\1$DATE/" module.prop 
sed -i "s/\(version=\).*/\1$VERSION/" module.prop

# Set description value in module.prop
DESCRIPTION="This Module will replace your android default Roboto font family with \"$NAME\" font family as your default android system font. For support join @MFFMDisc on telegram."
sed -i "s/\(description=\).*/\1$DESCRIPTION/" module.prop

#ID
#NEW_ID="mffm11_${NAME//[[:blank:]]/}"
#sed -i "s/^id=.*$/id=$NEW_ID/" module.prop
sed -i 's/\(id=\).*/\1mffm11/' module.prop

# Zip name - replace spaces
ZIP_NAME=${NAME// /} 

# Construct archive name
ARCHIVE_NAME="$ZIP_NAME"_v"$DATE"[MFFMv11].zip

# Files to zip 
FILES="Files META-INF module.prop customize.sh LICENSE"

# Create zip archive
zip -r "$ARCHIVE_NAME" $FILES

echo "Created archive: $ARCHIVE_NAME"