#!/bin/bash

source /home/tcs/devstack/openrc admin admin
source /home/tcs/creds

image=$1
netid=$(neutron net-list | awk '/private/ {print $2}')
location="http://10.127.150.73:81/html/repo_iso/$image"
name="openstack-$image"
floatingip_id="25c1bdb9-620c-4ece-afe6-126658adaae2"

if glance image-list| grep -q $image; then 
    nova boot --image openstack-$image --nic net-id=$netid --flavor 2 openstack-$image
    echo "Please wait while IP address is being retrieved"
    for i in {1..10};do echo -n;sleep 1;done
    ipaddress=$(nova list | grep openstack-$image | cut -d'=' -f2 | cut -d' ' -f1)
    echo $ipaddress
    port_id=$(neutron port-list | grep $ipaddress | cut -d '|' -f2)
    echo $port_id
    neutron floatingip-associate $floatingip_id $port_id
    floatingip=$(neutron floatingip-list | grep $ipaddress | cut -d '|' -f4)
    echo $floatingip

else 
    heat stack-create stack-$image -f /home/tcs/devstack/testing1.yaml --parameters "location_path=$location;name=$name"
    for i in {1..10};do echo uploading image to glance;sleep 2;done
    nova boot --image openstack-$image --nic net-id=$netid --flavor 2 openstack-$image
    echo "Please wait while IP address is being retrieved"
    for i in {1..10};do echo -n;sleep 1;done
    ipaddress=$(nova list | grep openstack-$image | cut -d'=' -f2 | cut -d' ' -f1)
    echo $ipaddress
    port_id=$(neutron port-list | grep $ipaddress | cut -d '|' -f2)
    echo $port_id
    neutron floatingip-associate $floatingip_id $port_id
    floatingip=$(neutron floatingip-list | grep $ipaddress | cut -d '|' -f4)
    echo $floatingip
fi
# sudo ip netns exec ${qrouter} ssh -i ~/.ssh/ssh_rsa -o StrictHostKeyChecking=no cirros@${IP1} ping -c 2 ${IP2}

python /home/tcs/DEVOPS_MIGRATION/myproject/db_ip.py "$floatingip" "$image"

if [ -z $floatingip ];then
    echo "No Host/IP-address found to configure zabbix monitoring..."
else
    echo "Configuring zabbix monitoring on host-$floatingip"
    sshpass -p tcs@12345 ssh -o stricthostkeychecking=no tcs@10.125.155.220 "/bin/bash /home/tcs/zabbix-api-integration/zabbix-api/zabbix-api-configure.sh $floatingip"
fi

