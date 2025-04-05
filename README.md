# EQX VLAN Modification
Adds or removes Layer 2 VLANs from ESXi servers in the Equinix (EQX) data centers.


## API Reference
API documentation is available at https://deploy.equinix.com/developers/api/metal/

## Requirements
**REQUIRES:**
This script requires the use of 'jq' to parse and work with curl data.  To install jq, you can run 'yum install jq' or 'apt-get install jq' etc.

This script requires the use of 'csvkit' to parse and work with .csv files.  To install csvkit, run 'pip install csvkit'.  For more information, please see https://csvkit.readthedocs.io/en/latest/

This script requires that you have a valid API Key within the Equinix Portal, with appropriate permissions to modify ESXi resources.  If you do not have an API Key, you will need to create one.

If you have moved files between Linux/Unix and Windows operating systems, you may need to convert the file carriage return in order to alow the script to run smoothly.  For this, I recommend the 'dos2unix' and 'unix2dos' commands.

## Execution
The script makes use of a rigid directory structure to maintain stability during changes on ESXi hosts.  The script should ONLY be run from a terminal on the local directory containing the "execute.sh" file.

This script assumes that you only want to modify "eth" (e.g. eth0, eth1, etc.) network interfaces.  If you need to modify "bond" interfaces (for example, some ESXi servers only have bond0 and bond1, but not eth interfaces), you will need to:
```
    A) update Line 17 of the 'get_instance_port_ids.sh' file to use '-r "^bond"' instead of '-r "^eth"'. 
    B) update the following line in the 'modify_vlan_on_esxi.sh' file:
        Pre-Prod:   PORT_ID=$(csvgrep -c InterfaceName -m bond0 $file | grep bond | cut -c 7-) # 'bond0 or bond1 are options for the -m parameter
        Prod:       PORT_ID=$(csvgrep -c InterfaceName -m eth2 $file | grep eth | cut -c 6-)
```
Finally, please note that this script assumes that there are less than 100 servers in the EQX Project.  If you have more than 100 servers active in your EQX Project, you will need to update the URL of the curl command in line 10 of the ***'gather_device_data.sh'*** script to be appended with something other than ***"?per_page=100"***.