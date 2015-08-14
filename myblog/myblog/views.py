#!/usr/bin/python
from myblog.forms import MyForm
import myblog.forms as form_data
from django.shortcuts import render
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect
import subprocess
 
'''def post_form_upload(request):
    if request.method == 'GET':
        form = PostForm()
    else:
        # A POST request: Handle Form Upload
        form = PostForm(request.POST) # Bind data from request.POST into a PostForm
 
        # If data is valid, proceeds to create a new post and redirect the user

        if form.is_valid():
	    import pdb;pdb.set_trace() 
            content = form.cleaned_data['content']
            created_at = form.cleaned_data['created_at']
            #post = m.Post.objects.create(content=content,
                   #                      created_at=created_at)
            #return HttpResponseRedirect(reverse('post_detail',
             #                                   kwargs={'post_id': 4}))
 
    return render(request, 'post_form_upload.html', {'form': form,})'''

def post_form_upload(request):
    #import pdb;pdb.set_trace()
    form = MyForm()
    return render(request, 'post_form.html',{'form': form})

#def get_values(request):
#    ext_ip=request.POST('ext_ip')

def process_value(key,value):
    value=str(value)
    DROP_DOWN={}
    DROP_DOWN['ext_mgmt_dd']=form_data.ext_mgmt
    DROP_DOWN['mgmt_subnet_dd']=form_data.mgmt_subnet
    DROP_DOWN['CONFIG_DEBUG_dd']=form_data.CONFIG_DEBUG
    DROP_DOWN['network_redundancy_dd']=form_data.network_redundancy
    DROP_DOWN['cinder_volume_dd']=form_data.cinder_volume
    DROP_DOWN['cinder_vg_percentage_dd']= form_data.cinder_vg_percentage
    DROP_DOWN['all_in_one_node_dd']= form_data.all_in_one_node
    DROP_DOWN['neutron_ovs_tenant_dd']= form_data.neutron_ovs_tenant
    DROP_DOWN['neutron_ovs_vlan_dd']= form_data.neutron_ovs_vlan
    DROP_DOWN['neutron_ovs_tunnel_dd']= form_data.neutron_ovs_tunnel
    DROP_DOWN['keyboard_layout_dd']= form_data.keyboard_layout
    DROP_DOWN['dnsserver_dd']= form_data.dnsserver
    DROP_DOWN['compute_1_enable_commission_dd']= form_data.compute_1_enable_commission
    DROP_DOWN['compute_1_host_name_dd']= form_data.compute_1_host_name
   
    if key in DROP_DOWN.keys():
        drop_down=DROP_DOWN[key]
        drop_down_dict=dict((x, y) for x, y in drop_down)
        #value1=int(value)
        value=drop_down_dict[value]
    return value

def process_form(request):
    #import pdb;pdb.set_trace()
    KEYS=['mgmt_subnet_dd' ,'all_in_one_node_dd' ,'controller_ip_text' ,'floating_sIP_text' ,'compute_ip_text' ,'host_ip_text' ,'openstack_admin_text','keyboard_layout_dd','floating_eIP' ,'compute_1_enable_commission_dd' ,'network_redundancy_dd' ,'controller_hname_text' ,'neutron_ovs_tunnel_dd' ,'controller1_mac1_text' ,'openstack_demo_password' ,'host_pwd_text','CONFIG_DEBUG_dd' ,'host_uname_text','floatingip_text','compute_1_host_name_dd','compute_mac_text','ext_mgmt_dd' ,'neutron_ovs_vlan_dd' ,'neutron_ovs_tenant_dd' ,'ext_ip_text','cinder_volume_dd' ,'controller_mac_text' ,'compute1_mac1_text' ,'controller_mac1_text' ,'compute_mac1_text']
    DROP_DOWN={}
    data1={}
    values=map(lambda x: process_value(x,request.POST.get(x)),KEYS)
    print values
    index=0
    for key in KEYS:
        data1[key]=values[index]
        index+=1
    
    #import pdb;pdb.set_trace()
    file_open=open('test.conf','wr')
    for k in KEYS:
        #import pdb;pdb.set_trace()
        data=str(k)+'='+str(data1[k])+'\n'
        file_open.write(data)
    file_open.close()  
    return render(request, 'form_upload.html')

def process_form_data(request):
    KEYS=['ext_mgmt_iface','mgmt_subnet','ext_ip','cinder_volume_group','cinder_vg_percentage_on_hdd','neutron_ovs_tenant_network_type','neutron_ovs_tunnel_ranges','dnsserver','floating_sIP','floating_eIP','floatingip','controller_mac','controller_mac1','controller_ip','controller1_mac1','controller_hname','openstack_admin','openstack_demo']
    values=map(lambda x: str(request.POST.get(x)),KEYS)
    #print values
    index=0
    #DROP_DOWN={}
    data1={}
    for key in KEYS:
        data1[key]=values[index]
        index+=1

    #import pdb;pdb.set_trace()
    file_open=open('/home/tcs/Documents/735142/myblog/myblog/test.conf','wr')
    for k in KEYS:
        #import pdb;pdb.set_trace()
        data=str(k)+'='+str(data1[k])+'\n'
        file_open.write(data)
    file_open.close()
    p= subprocess.Popen(["/bin/bash","/home/tcs/Documents/735142/myblog/myblog/test_conf.sh"], stdout=subprocess.PIPE)
    output, err = p.communicate()
    print output
#   file_open.close()
    return render(request, 'form_upload.html')
 

