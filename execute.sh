#!/bin/bash

echo -e "
#######################################################################
Please ensure you are running this script from the top-level directory,
i.e. from the directory containing 'execute.sh'.

This script requires the use of 'csvkit' to parse and work with .csv files.
To install csvkit, run 'pip install csvkit'.
For more information, please see https://csvkit.readthedocs.io/en/latest/
#######################################################################\n\n"

# Create empty directory if DNE or cleanup from previous script execution, if any
mkdir -p ./generated_files
rm -f ./generated_files/*

# Create static variables and read user input for other variables
CSV_MASTER_FILE_NAME=$(date +"%Y-%m-%d").csv
read -p "Enter Project ID: " PROJECT_ID
read -sp "Enter your API Auth Key: " EQX_AUTH_TOKEN 
echo
read -p "What is the regex pattern for the subset of ESXi Hostnames you'd like to work on? " ESXI_PATTERN
read -p "Are you adding or removing a VLAN from EQX ESXi servers? 
Please choose 'add' or 'remove': " VLAN_ACTION
read -p "What is the VLAN ID you would like to add/remove? If multiple VLANs, use commas to separate VLANs: " VLAN_ID
read -p "On which network interfaces (eth0, eth1, eth2, eth3) would you like to apply the change?
  Options to choose from are:
    - Choose 'even' for eth0 & eth2;
    - Choose 'odd' for eth1 and eth3;
    - Choose 'all' for all;
    - Choose 'single' for a single interface: " ETH_CHOICE

# Trim VLAN List
echo $VLAN_ID > ./generated_files/vlan_list_raw.txt
cat ./generated_files/vlan_list_raw.txt | tr "," "\n" | tr -d "^ " > ./generated_files/vlan_list_trimmed.txt

# Export necessary environment variables for subscripts
export CSV_MASTER_FILE="./generated_files/$CSV_MASTER_FILE_NAME"
export PROJECT_ID=$PROJECT_ID
export EQX_AUTH_TOKEN=$EQX_AUTH_TOKEN
export ETH_CHOICE=$ETH_CHOICE
export VLAN_ACTION=$VLAN_ACTION

# Create CSVs for user-selected ESXi servers
bash ./required_files/gather_device_data.sh
csvgrep -c Hostname -r $ESXI_PATTERN $CSV_MASTER_FILE > ./generated_files/action_esxi_list.csv

# Review and confirm ESXi names and actions, then continue or exit
echo
echo -e "You are about to $VLAN_ACTION VLAN $VLAN_ID on the following EQX ESXi servers:"
csvcut -c Hostname,"Device ID" ./generated_files/action_esxi_list.csv | csvlook
echo
read -p "Are you certain you would like to continue?  Enter 'yes' to continue: " CONFIRM_EXECUTE
echo


case $CONFIRM_EXECUTE in 
  yes)
    # Perform API action for VLANs in ./generated_files/vlan_list_trimmed.txt
    while IFS= read -r VLAN_ID; do
        export VLAN_ID=$VLAN_ID
        bash ./required_files/modify_vlan_on_esxi.sh
    done < ./generated_files/vlan_list_trimmed.txt
    ;;
  *)
    echo "The script will now exit.  No changes have been made."
    exit
    ;;
esac


