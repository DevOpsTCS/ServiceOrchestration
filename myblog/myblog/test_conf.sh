#!/bin/bash -x

. /home/tcs/Documents/735142/myblog/myblog/test.conf 

#cat /home/tcs/kavya/myblog/myblog/test.conf

echo "1 $ext_mgmt_iface"
echo "2 $mgmt_subnet"
echo "3 $ext_ip"
echo "4 $cinder_volume_group"
echo "5 $cinder_vg_percentage_on_hdd"
echo "6 $neutron_ovs_tenant_network_type"
echo "7 $neutron_ovs_tunnel_ranges"
echo "8 $dnsserver"
echo "9 $floating_sIP"
echo "10 $floating_eIP"
echo "11 $floatingip"
echo "12 $controller_mac"
echo "13 $controller_mac1"
echo "14 $controller_ip"
echo "15 $controller1_mac1"
echo "16 $controller_hname"
echo "17 $openstack_admin"
echo "18 $openstack_demo"
