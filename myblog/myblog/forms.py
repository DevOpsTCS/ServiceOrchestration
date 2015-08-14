from django import forms
 
'''class PostForm(forms.Form):
    content = forms.CharField(max_length=256)
    created_at = forms.DateTimeField()'''

ext_mgmt = (
    ('1', 'eth2'),
    #(2', 'Option 2'),
   #('3', 'Option 3'),
)
mgmt_subnet = (
    ('1',24),
)
CONFIG_DEBUG = (
    ('1','y'),
    ('2','n'),
)
network_redundancy = (
    ('1','y'),
    ('2','n'),
)
cinder_volume = (
    ('1','10GB'),
)
cinder_vg_percentage = (
    ('1',''),
)
all_in_one_node = (
    ('1','y'),
    ('2','n'),
)
neutron_ovs_tenant = (
    ('1','local'),
)
neutron_ovs_vlan = (
    ('1','100:1000'),
)
neutron_ovs_tunnel = (
    ('1','1:1000'),
)
keyboard_layout = (
    ('1','us'),
)
dnsserver = (
    ('1',''),
)
compute_1_enable_commission = (
    ('1','y'),
    ('2','n'),
)
compute_1_host_name = (
    ('1','devops-compute'),
)

    
class MyForm(forms.Form):
    ext_mgmt_dd = forms.ChoiceField(choices=ext_mgmt)
   
    mgmt_subnet_dd=forms.ChoiceField(choices=mgmt_subnet)
    
    CONFIG_DEBUG_dd=forms.ChoiceField(choices=CONFIG_DEBUG)
    network_redundancy_dd=forms.ChoiceField(choices=network_redundancy)
    cinder_volume_dd=forms.ChoiceField(choices=cinder_volume)
    cinder_vg_percentage_dd = forms.ChoiceField(choices=cinder_vg_percentage)
    all_in_one_node_dd = forms.ChoiceField(choices=all_in_one_node)
    neutron_ovs_tenant_dd = forms.ChoiceField(choices=neutron_ovs_tenant)
    neutron_ovs_vlan_dd = forms.ChoiceField(choices=neutron_ovs_vlan)
    neutron_ovs_tunnel_dd = forms.ChoiceField(choices=neutron_ovs_tunnel)
    keyboard_layout_dd = forms.ChoiceField(choices=keyboard_layout)
    dnsserver_dd = forms.ChoiceField(choices=dnsserver)
    compute_1_enable_commission_dd = forms.ChoiceField(choices=compute_1_enable_commission)
    compute_1_host_name_dd = forms.ChoiceField(choices=compute_1_host_name)
    









