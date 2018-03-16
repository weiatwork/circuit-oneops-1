require 'fog/azurerm'

require File.expand_path('../../../azure_base/libraries/utils.rb', __FILE__)
require File.expand_path('../../libraries/network_security_group.rb', __FILE__)
require File.expand_path('../../../azure/libraries/network_interface_card.rb', __FILE__)

# set the proxy if it exists as a cloud var
Utils.set_proxy(node['workorder']['payLoad']['OO_CLOUD_VARS'])

cloud_name = node['workorder']['cloud']['ciName']

compute_service = node['workorder']['services']['compute'][cloud_name]['ciAttributes']

credentials = {
  tenant_id: compute_service[:tenant_id],
  client_secret: compute_service[:client_secret],
  client_id: compute_service[:client_id],
  subscription_id: compute_service[:subscription]
}

location = compute_service[:location]

nic_client = AzureNetwork::NetworkInterfaceCard.new(credentials)

previous_nsg_id = if node['workorder']['rfcCi']['ciBaseAttributes']['net_sec_group_id'].nil?
                    node['workorder']['rfcCi']['ciAttributes']['net_sec_group_id']
                  else
                    node['workorder']['rfcCi']['ciBaseAttributes']['net_sec_group_id']
                  end

# Get resource group name
rg_manager = AzureBase::ResourceGroupManager.new(node)
resource_group_name = rg_manager.rg_name

nic_client.rg_name = resource_group_name
nic_client.flag = false

nic_list = nic_client.get_all_nics_in_rg(resource_group_name)

nics = []
nic_list.each do |nic_object|
  nics << nic_object if nic_object.network_security_group_id == previous_nsg_id
end

include_recipe 'azuresecgroup::add_net_sec_group'

nsg_id = node['updated_nsg_id']

nics.each do |nic|
  nic.network_security_group_id = nsg_id
  nic_client.create_update(nic)
end
