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
nsg_client = AzureNetwork::NetworkSecurityGroup.new(credentials)

ns_path_parts = node['workorder']['rfcCi']['nsPath'].split('/')
org = ns_path_parts[1]
assembly = ns_path_parts[2]
environment = ns_path_parts[3]
platform_ci_id = node['workorder']['box']['ciId']

previous_nsg_id = if node['workorder']['rfcCi']['ciBaseAttributes']['net_sec_group_id'].nil?
                    node['workorder']['rfcCi']['ciAttributes']['net_sec_group_id']
                  else
                    node['workorder']['rfcCi']['ciBaseAttributes']['net_sec_group_id']
                  end

resource_group_name = AzureResources::ResourceGroup.get_name(org, assembly, platform_ci_id, environment, location)

nic_client.rg_name = resource_group_name
nic_client.flag = false

nic_list = nic_client.get_all_nics_in_rg(resource_group_name)

nics = []
nic_list.each do |nic_object|
  if nic_object.network_security_group_id == previous_nsg_id
    nics << nic_object
  end
end

nsg_resource_group_name = Utils.get_nsg_rg_name(location)

nsg_version = 0
all_nsgs_in_rg = nil
matched_nsgs = []
pack_name = Utils.get_pack_name(node)

all_nsgs_in_rg = nsg_client.list_security_groups(nsg_resource_group_name)
matched_nsgs = nsg_client.get_matching_nsgs(all_nsgs_in_rg, pack_name)
nsg_version = matched_nsgs.count

network_security_group_name = Utils.get_network_security_group_name(node, nsg_version + 1)

sec_rules = nsg_client.get_sec_rules_definition(node, network_security_group_name, nsg_resource_group_name)

unless matched_nsgs.empty?
  matched_nsg_name = nsg_client.match_nsg_rules(matched_nsgs, sec_rules)
  unless matched_nsg_name.nil?
    matched_nsg = nsg_client.get(nsg_resource_group_name, matched_nsg_name)
    nics.each do |nic|
      nic.network_security_group_id = matched_nsg.id
      nic_client.create_update(nic)
    end
    return
  end
end

parameters = Fog::Network::AzureRM::NetworkSecurityGroup.new
parameters.location = location
parameters.security_rules = sec_rules

nsg_result = nsg_client.create_update(nsg_resource_group_name, network_security_group_name, parameters)

puts "***RESULT:net_sec_group_id=" + nsg_result.id

nics.each do |nic|
  nic.network_security_group_id = nsg_result.id
  nic_client.create_update(nic)
end

if !nsg_result.nil?
  Chef::Log.info("The network security group has been created\n\rid: '#{nsg_result.id}'\n\r'#{nsg_result.location}'\n\r'#{nsg_result.name}'\n\r")
else
  raise 'Error creating network security group'
end
