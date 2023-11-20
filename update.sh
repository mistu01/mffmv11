#!/bin/bash

# Function to extract a zip archive and perform other operations
extract_zip() {
    # Prompt user for the zip file name
    read -p "Enter the name of the zip file to extract: " zip_name

    # Check if the zip file exists
    if [ -f "$zip_name" ]; then
        # Extract the zip file into a directory with the same name
        folder_name=$(basename -s .zip "$zip_name")
        mkdir "$folder_name"
        unzip "$zip_name" -d "$folder_name"
        echo "Extracted $zip_name to ./$folder_name/"

        # Files to copy from the extracted directory's Files folder to the current working directory's Files folder
        files_to_copy=("Black.ttf" "BlackItalic.ttf" "Bold.ttf" "BoldItalic.ttf" "Medium.ttf" "MediumItalic.ttf" "Regular.ttf" "Italic.ttf" "Light.ttf" "LightItalic.ttf")

        for file in "${files_to_copy[@]}"; do
            if [ -f ./"$folder_name"/Files/"$file" ]; then
                cp ./"$folder_name"/Files/"$file" Files/
                echo "Copied $file to Files/"
            else
                echo "$file not found in $folder_name/Files/"
            fi
        done

        # Replace the value of 'name' in module.prop
        extracted_name=$(grep -oP '(?<=^name=).*' ./"$folder_name"/module.prop)
        if [ -f module.prop ]; then
            sed -i "s/^name=.*/name=$extracted_name/" module.prop
            echo "Replaced 'name' value in module.prop with '$extracted_name'"

            # Replace 'version' and 'versionCode' values in module.prop
            sed -i "s/^version=.*/version=$(date +'%Y.%m.%d')/" module.prop
            sed -i "s/^versionCode=.*/versionCode=$(date +'%Y%m%d')/" module.prop
            echo "Updated 'version' to '$(date +'%Y.%m.%d')' and 'versionCode' to '$(date +'%Y%m%d')' in module.prop"

            # Create a new zip file with the specified content and naming format
            create_new_zip

            # Clean up: Delete the extracted directory
            if [ -d "$folder_name" ]; then
                rm -rf "$folder_name"
                echo "Deleted extracted directory: $folder_name"
            fi
        else
            echo "Current directory does not contain a module.prop file."
        fi
    else
        echo "Zip file '$zip_name' not found."
    fi
}

# Function to create a new zip file with specified content and naming format
create_new_zip() {
    # Get today's date in the required format for the zip archive name
    today_date=$(date +'%Y%m%d')

    # Prompt user for the new zip file name
    read -p "Enter the name for the new zip file: " zip_name_input

    # Check if the zip file name input is provided
    if [ -n "$zip_name_input" ]; then
        # Create a new zip file with the specified content and naming format
        new_zip_name="$zip_name_input"_v"$today_date"[MFFMv11].zip
        zip -r "$new_zip_name" Files META-INF LICENSE module.prop customize.sh
        echo "Created new zip archive: $new_zip_name"
    else
        echo "Invalid input for the zip file name."
    fi
}

# Call the function to extract the zip archive and perform other operations
extract_zip
