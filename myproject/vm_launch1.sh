#!/bin/bash -x

source /home/tcs/devstack/openrc admin admin
source /home/tcs/creds
image=$1
netid=$(neutron net-list | awk '/private/ {print $2}')
location="http://10.127.150.73:81/html/repo_iso/$image"
name="openstack-$image"
floatingip_id="5a0f1855-aa51-4319-8200-fe7888a44726"

if glance image-list| grep -q $image; then 
    nova boot --image openstack-$image --nic net-id=$netid --flavor e736eba8-c9e5-4e26-92c1-2afb429c8ad1 \
        openstack-$image
    echo "Please wait while IP address is being retrieved"
    while [ 1 ]; do      
        status=$(nova list |grep "openstack-$image" | awk '{print $6}')
        if [[ $status == "ACTIVE" ]]; then
            ipaddress=$(nova list | grep openstack-$image | \
                awk '{print $12}'|  cut -d '=' -f2)
            port_id=$(neutron port-list | grep $ipaddress | cut -d '|' -f2)
            neutron floatingip-associate $floatingip_id $port_id
            floatingip=$(neutron floatingip-list | grep $ipaddress | \
                cut -d '|' -f4)
            break
        else
            for i in {1..10};do echo -n .;sleep 1;done
            continue
        fi
    done
else 
    heat stack-create stack-$image -f /home/tcs/devstack/testing1.yaml --parameters "location_path=$location;name=$name"
    echo "uploading image to glance"
    for i in {1..10};do echo -n .;sleep 2;done
    nova boot --image openstack-$image --nic net-id=$netid --flavor e736eba8-c9e5-4e26-92c1-2afb429c8ad1 openstack-$image
    echo "Please wait while IP address is being retrieved"
    while [ 1 ]; do
        status=$(nova list |grep "openstack-$image" | awk '{print $6}')
        if [[ $status == "ACTIVE" ]]; then
            ipaddress=$(nova list | grep openstack-$image | awk '{print $12}'|  cut -d '=' -f2)
            port_id=$(neutron port-list | grep $ipaddress | cut -d '|' -f2)
            neutron floatingip-associate $floatingip_id $port_id
            floatingip=$(neutron floatingip-list | grep $ipaddress | cut -d '|' -f4)
            break
        else
            for i in {1..10};do echo -n .;sleep 1;done
            continue
        fi
    done
fi
# sudo ip netns exec ${qrouter} ssh -i ~/.ssh/ssh_rsa -o StrictHostKeyChecking=no cirros@${IP1} ping -c 2 ${IP2}

python /home/tcs/DEVOPS_MIGRATION/myproject/db_ip.py "$floatingip" "$image"

if [ -z $floatingip ];then
    echo "No Host/IP-address found to configure zabbix monitoring..."
else
    echo "Configuring zabbix monitoring on host-$floatingip"
    sshpass -p tcs@12345 ssh -o stricthostkeychecking=no tcs@10.125.155.220 "/bin/bash /home/tcs/zabbix-api-integration/zabbix-api/zabbix-api-configure.sh $floatingip"
fi

