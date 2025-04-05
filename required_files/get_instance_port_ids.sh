#!/bin/bash

# Get Instance Port IDs for desired subset of ESXi to be worked on

# Make lists for for loops
csvcut -c 'Device ID' ./generated_files/action_esxi_list.csv | sed 1d > ./generated_files/action_device_id_list.txt

for id in $(cat ./generated_files/action_device_id_list.txt)
do
  echo "InterfaceName,PortID" > ./generated_files/$id.csv
  curl --request GET \
    --url https://api.equinix.com/metal/v1/devices/$id \
    --header 'Content-Type: application/json' \
    --header "X-Auth-Token: $EQX_AUTH_TOKEN" | 
    jq '.network_ports[] | .name + "," + .id' >> ./generated_files/$id.csv
    sed 's/\"//g' ./generated_files/$id.csv > ./generated_files/temp_$id.csv
    csvgrep -c InterfaceName -r "^eth" ./generated_files/temp_$id.csv > ./generated_files/eth_$id.csv

    # Clean placeholder files
    rm -f ./generated_files/$id.csv ./generated_files/temp_$id.csv
done

