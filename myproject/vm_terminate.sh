#!/bin/bash
image=$1
vmname="openstack-$1"
floatingip_id="5a0f1855-aa51-4319-8200-fe7888a44726"

ipaddress=$(mysql -uroot -D Devops -e "select image_name,Deployed_VM_IP from devops_images;" | awk '/'$image'/ {print $2}')
if [ -z $ipaddress ];then
    echo "Unable to fetch ipaddress to stop zabbix monitoring..."
else
    echo "Deleting configuration to stop zabbix monitoring on host-$ipaddress"
    sshpass -p tcs@12345 ssh -o stricthostkeychecking=no tcs@10.125.155.220 "/bin/bash /home/tcs/zabbix-api-integration/zabbix-api/zabbix-api-delete-configure.sh $ipaddress"
fi

source /home/tcs/creds
source /home/tcs/devstack/openrc admin admin
ipaddress=$(nova list | grep openstack-$image | cut -d'=' -f2 | cut -d' ' -f1)
echo $ipaddress
port_id=$(neutron port-list | grep $ipaddress | cut -d '|' -f2)
echo $port_id
neutron floatingip-disassociate $floatingip_id $port_id
nova delete $vmname
list=$(nova list)
echo $list

floatingip='-'
python /home/tcs/DEVOPS_MIGRATION/myproject/db_ip.py "$floatingip" "$image"

