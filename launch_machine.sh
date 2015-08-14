#!/bin/bash -x

. /home/tcs/DEVOPS/launch_machine.conf

##################################################################
# TODO
# Temporary handling
while [ 1 ];do
    vm_count=$(sudo virsh list | wc -l)
    if [ $vm_count -ge 5 ];then
        #virsh destroy $vm_name
        #virsh undefine $vm_name
        echo "WAIT : One or more JOBS already in progress..."
        sleep 5
        continue
    else
        echo "No JOBs in progress. Good to GO..."
        break
    fi
done
##################################################################

echo "Please wait while fresh file is being prepared..." 

if [ '$(sudo ls -A $repo_path) > /dev/null 2>&1' ];then
    sudo ls -lhrt $repo_path/* > temp.file
    counter=$(awk END'{print $NF}' temp.file |cut -d- -f3 | cut -d. -f1)
    let counter++
    let counter++
#    mv $disk_name $repo_path/devops-build-${counter}.qcow2
    rm -f temp.file
    img_name="devops-build-${counter}"
else
    img_name="devops-build-2"
fi


# Preparing fresh image for deployment
#cp -f $orginal_path/$orig_disk_name $repo_path/$disk_name
sudo rsync -ah --progress $orginal_path/$orig_disk_name $repo_path/$disk_name
# Changing directory to temprary
cd $repo_path

# VM IP Address reset
if [[ -f $IPA_file ]] ; then
    rm -rf $IPA_file
    touch $IPA_file
fi

sudo virt-install --name $vm_name --ram 2048 --disk $disk_name,bus=virtio,format=qcow2 --boot hd --network bridge=$_bridge --noautoconsole > /dev/null 2>&1

if [[ $? = 0 ]] ; then
    sudo ip neigh flush all > /dev/null;
    sudo fping -c 1 -g -q $host_subnet 2> /dev/null;
    echo -n "Please wait while the IP Address is being retrieved.."
#    sleep 10
    for i in {1..10};do echo -n .;sleep 1;done
    while [ 1 ] ; do
        for mac in `virsh domiflist $vm_name |grep -o -E "([0-9a-f]{2}:){5}([0-9a-f]{2})"` ; do 
            ipaddress=$(arp -n |grep $mac | awk '{print $1}')
        done
#        sleep 5
        for i in {1..5};do echo -n .;sleep 1;done
        echo -n "${ipaddress:-.}"
        sudo ip neigh flush all > /dev/null;
        sudo fping -c 1 -g -q $host_subnet 2> /dev/null;
        if [ $ipaddress ];then echo " -OK";break;fi
#        sleep 10
        for i in {1..10};do echo -n .;sleep 2;done
    done
    sudo rm -rf .ssh/known_hosts 
    if [ ! -z $ipaddress ] ; then
        touch $IPA_file
        echo $ipaddress >> $IPA_file
        if [ "$repo_opt" == "gerrit" ]; then 
            sshpass -p $password ssh -o StrictHostKeyChecking=no -l $username $ipaddress "git clone http://$gerrit_user@$git_ip:$gerrit_port/${git_repo}.git"
        fi
        if [ "$repo_opt" == "git" ]; then 
            sshpass -p $password ssh -o StrictHostKeyChecking=no -l $username $ipaddress "git clone http://$git_user:$git_password@$git_ip/root/${git_repo}.git" > /dev/null 2>&1
        fi
        sshpass -p $password ssh -o StrictHostKeyChecking=no -l $username $ipaddress \
        "\
        echo \"#!/bin/bash\" > /home/tcs/${git_repo}/run-application;\
        sudo chmod +x /home/tcs/${git_repo}/run-application;\
        echo \"/usr/bin/python /home/tcs/${git_repo}/orchestrationUI/manage.py runserver --insecure 0.0.0.0:1234 > /tmp/server.log &\" >> /home/tcs/${git_repo}/run-application;\
        sudo cp /home/tcs/${git_repo}/run-application /etc/init.d/;\
        sudo update-rc.d run-application start 99 2 .;\
        unset http_proxy https_proxy ftp_proxy socks_proxy all_proxy;\
        "
        sed -i 's/'$disk_name'/'$img_name'/' /home/tcs/DEVOPS/launch_machine.conf
    fi 
fi

if [ "$kill" ];then
    sudo virsh shutdown $vm_name > /dev/null 2>&1
    echo -n "Finalising $disk_name please wait.."
    while [ 1 ];do
        if virsh list --all | grep $vm_name | grep -q "shut off";then
            sudo virsh undefine $vm_name > /dev/null 2>&1
            echo " -OK"
            break
        else
            sleep 1
            echo -n "."
        fi
    done
fi
sudo rm -rf .ssh/known_hosts

# Updating database
echo -n "Updating Deployment database..."
if [ -f /home/tcs/DEVOPS/UT_url.txt ] && [ -f /home/tcs/DEVOPS/FT_url.txt ];then
    UT_url="$(sudo cat /home/tcs/DEVOPS/UT_url.txt)"
    FT_url="$(sudo cat /home/tcs/DEVOPS/FT_url.txt)"
    sed 's|UT_URL|'$UT_url'|g;s|FT_URL|'$FT_url'|g;s|IMAGE|'$disk_name'|g' $db_url_template > $db_file && echo " -OK"
else
    sed 's/EXECUTION_ID/'$BUILD_NUMBER'/g;s/IMAGE/'$disk_name'/g' $db_template > $db_file && echo " -OK"
fi
sshpass -p $password ssh -o StrictHostKeyChecking=no -l $db_username $db_ipaddress "mysql -uroot -D Devops -e '$(cat $db_file)'" > /dev/null 2>&1
 
cd -

#sleep 3

#/usr/bin/python launch_machine.py $disk_name

#------------------------------------------------------------------------------------------------------------------------

#        echo \"/home/tcs/${git_repo}/orchestrationUI/monitor.sh > /home/tcs/monitor.log &\" >> /home/tcs/${git_repo}/run-application;\

#        awk '!/#/ && /exit 0/{print \"/home/tcs/${git_repo}/orchestrationUI/monitor.sh > /home/tcs/monitor.log &;\n/usr/bin/python /home/tcs/${git_repo}/orchestrationUI/manage.py runserver 0.0.0.0:1234 > /tmp/server.log &;\"}1' /etc/rc.local > /home/tcs/${git_repo}/startup;sudo cp /home/tcs/${git_repo}/startup /etc/rc.local;\
#        while [ $(sshpass -p $password ssh -o StrictHostKeyChecking=no -l $username $ipaddress "cat /home/tcs/${git_repo}/run-application.sh | wc -l") -lt 3 ];do
#            sshpass -p $password ssh -o StrictHostKeyChecking=no -l $username $ipaddress \
#            "echo \"/home/tcs/${git_repo}/orchestrationUI/monitor.sh > /home/tcs/monitor.log &\" >> /home/tcs/${git_repo}/run-application.sh;echo \"/usr/bin/python /home/tcs/${git_repo}/orchestrationUI/manage.py runserver 0.0.0.0:1234 > /tmp/server.log &\" >> /home/tcs/${git_repo}/run-application.sh;unset http_proxy https_proxy ftp_proxy socks_proxy all_proxy;\
#            "
#        done
#        awk '!/#/ && /exit 0/{print \"[ -f /home/tcs/${git_repo}/run-application.sh ] && /home/tcs/${git_repo}/run-application.sh\"}1' /etc/rc.local > /home/tcs/${git_repo}/startup;sudo cp /home/tcs/${git_repo}/startup /etc/rc.local;\

#sshpass -p tcs@12345 ssh -o StrictHostKeyChecking=no -l tcs 10.127.150.39 "[ -f jenkins/devops/VMFT_DEMO.txt ] && rm -rf jenkins/devops/VMFT_DEMO.txt ; cp jenkins/devops/VMFT_DEMO.template jenkins/devops/VMFT_DEMO.txt ; sed -i 's/PLACE_HOLDER/\$ipaddress/g' jenkins/devops/VMFT_DEMO.txt
#        /home/tcs/${git_repo}/orchestrationUI/monitor.sh > /home/tcs/monitor.log & /usr/bin/python /home/tcs/${git_repo}/orchestrationUI/manage.py runserver 0.0.0.0:1234 > /tmp/server.log &
