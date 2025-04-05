#!/bin/bash

# Define Functions
case_action () {
case $VLAN_ACTION in
  add)
    curl --request POST \
    --url https://api.equinix.com/metal/v1/ports/$PORT_ID/assign \
    --header 'Content-Type: application/json' \
    --header "X-Auth-Token: $EQX_AUTH_TOKEN" \
    --data '{"vnid": "'$VLAN_ID'"}'
    ;;
  remove)
    curl --request POST \
    --url https://api.equinix.com/metal/v1/ports/$PORT_ID/unassign \
    --header 'Content-Type: application/json' \
    --header "X-Auth-Token: $EQX_AUTH_TOKEN" \
    --data '{"vnid": "'$VLAN_ID'"}'
    ;;
esac
}

# Get ESXi Instance Port IDs
echo -e "Gathering ESXi Interface Port ID Data..."
bash ./required_files/get_instance_port_ids.sh
echo

# For each ESXi Device matching user-defined regex pattern, perform ASSIGN VLAN action 
case $ETH_CHOICE in
  even)
    for file in $(ls ./generated_files/eth*.csv)
      do
      PORT_ID=$(csvgrep -c InterfaceName -m eth0 $file | grep eth | cut -c 6-)
      case_action
      echo -e "\nVLAN $VLAN_ID has been updated on eth0 for PORT ID $PORT_ID.\n"

      PORT_ID=$(csvgrep -c InterfaceName -m eth2 $file | grep eth | cut -c 6-)
      case_action
      echo -e "\nVLAN $VLAN_ID has been updated on eth2 for PORT ID $PORT_ID.\n"
      done
    ;;
  odd)
    for file in $(ls ./generated_files/eth*.csv)
      do
      PORT_ID=$(csvgrep -c InterfaceName -m eth1 $file | grep eth | cut -c 6-)
      case_action
      echo -e "\nVLAN $VLAN_ID has been updated on eth1 for PORT ID $PORT_ID.\n"

      PORT_ID=$(csvgrep -c InterfaceName -m eth3 $file | grep eth | cut -c 6-)
      case_action
      echo -e "\nVLAN $VLAN_ID has been updated on eth3 for PORT ID $PORT_ID.\n"
      done
    ;;
  all)
    for file in $(ls ./generated_files/eth*.csv)
      do
      PORT_ID=$(csvgrep -c InterfaceName -m eth0 $file | grep eth | cut -c 6-)
      case_action
      echo -e "\nVLAN $VLAN_ID has been updated on eth0 for PORT ID $PORT_ID.\n"

      PORT_ID=$(csvgrep -c InterfaceName -m eth1 $file | grep eth | cut -c 6-)
      case_action
      echo -e "\nVLAN $VLAN_ID has been updated on eth1 for PORT ID $PORT_ID.\n"

      PORT_ID=$(csvgrep -c InterfaceName -m eth2 $file | grep eth | cut -c 6-)
      case_action
      echo -e "\nVLAN $VLAN_ID has been updated on eth2 for PORT ID $PORT_ID.\n"

      PORT_ID=$(csvgrep -c InterfaceName -m eth3 $file | grep eth | cut -c 6-)
      case_action
      echo -e "\nVLAN $VLAN_ID has been updated on eth3 for PORT ID $PORT_ID.\n"
      done
    ;;
  single)
    read -p "Which single interface would you like to update?
    Choose from 'eth0', 'eth1', 'eth2', or 'eth3': " ETH_SINGLE
    
    for file in $(ls ./generated_files/eth*.csv)
      do
      echo -e "Working on $file ..."
      PORT_ID=$(csvgrep -c InterfaceName -m $ETH_SINGLE $file | grep eth | cut -c 6-)
      case_action
      done
    echo -e "\nVLAN $VLAN_ID has been updated on $ETH_SINGLE for PORT ID $PORT_ID.\n"
    ;;
esac