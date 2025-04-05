#!/bin/bash

# Get data for entire project.  
# This will be saved to a script-static local .json file.
# From that static .json file, CSVs can be created and parsed 
# to execute commands based on specific hostname values.

# Define commands
GET_DEVICE_METADATA="curl --request GET \
    --url https://api.equinix.com/metal/v1/projects/$PROJECT_ID/devices?per_page=100 \
    --header 'Content-Type: application/json' \
    --header 'X-Auth-Token: $EQX_AUTH_TOKEN'"
GET_DEVICE_HOSTNAME="jq '.devices | .[].hostname' ./generated_files/device_metadata.json"
GET_DEVICE_ID="jq '.devices | .[].id' ./generated_files/device_metadata.json"

# Create static json and temporary CSV files for each type of data needed.
eval $GET_DEVICE_METADATA > ./generated_files/device_metadata.json
eval $GET_DEVICE_HOSTNAME > ./generated_files/hostname.csv
eval $GET_DEVICE_ID > ./generated_files/id.csv

# Create and sort by hostname the CSV for entire project's data
echo "Hostname,Device ID" > $CSV_MASTER_FILE
paste -d ',' ./generated_files/hostname.csv ./generated_files/id.csv >> $CSV_MASTER_FILE
csvsort -c Hostname $CSV_MASTER_FILE > ./generated_files/sorted_master.csv
mv -f ./generated_files/sorted_master.csv $CSV_MASTER_FILE

# Remove temporary CSV files
rm ./generated_files/hostname.csv
rm ./generated_files/id.csv

