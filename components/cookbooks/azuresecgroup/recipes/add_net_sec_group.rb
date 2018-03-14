require File.expand_path('../../libraries/network_security_group.rb', __FILE__)
require File.expand_path('../../../azure_base/libraries/logger.rb', __FILE__)
require File.expand_path('../../../azure_base/libraries/utils.rb', __FILE__)
require File.expand_path('../../../azure/libraries/resource_group.rb', __FILE__)

# set the proxy if it exists as a cloud var
Utils.set_proxy(node['workorder']['payLoad']['OO_CLOUD_VARS'])

# get all necessary info from node
cloud_name = node['workorder']['cloud']['ciName']
compute_service = node['workorder']['services']['compute'][cloud_name]['ciAttributes']
credentials = {
    tenant_id: compute_service['tenant_id'],
    client_secret: compute_service['client_secret'],
    client_id: compute_service['client_id'],
    subscription_id: compute_service['subscription']
}

location = compute_service[:location]
rg = AzureResources::ResourceGroup.new(compute_service)
nsg = AzureNetwork::NetworkSecurityGroup.new(credentials)

if cloud_name =~ %r/\S+-wm-oc/ # OLD CODE START
  ns_path_parts = node['workorder']['rfcCi']['nsPath'].split('/')
  org = ns_path_parts[1]
  assembly = ns_path_parts[2]
  environment = ns_path_parts[3]
  platform_ci_id = node['workorder']['box']['ciId']

  network_security_group_name = node[:name]

  # Get resource group name
  resource_group_name = AzureResources::ResourceGroup.get_name(org, assembly, platform_ci_id, environment, location)

  sec_rules = nsg.get_sec_rules_definition(node, network_security_group_name, resource_group_name)

  parameters = Fog::Network::AzureRM::NetworkSecurityGroup.new
  parameters.location = location
  parameters.security_rules = sec_rules

  nsg_result = nsg.create_update(resource_group_name, network_security_group_name, parameters)

  if !nsg_result.nil?
    Chef::Log.info("The network security group has been created\n\rid: '#{nsg_result.id}'\n\r'#{nsg_result.location}'\n\r'#{nsg_result.name}'\n\r")
  else
    raise 'Error creating network security group'
  end

elsif cloud_name =~ %r/\S+-wm-nc/ # NEW CODE START
  resource_group_name = Utils.get_nsg_rg_name(location)

  nsg_version = 0
  all_nsgs_in_rg = nil
  matched_nsgs = []
  pack_name = Utils.get_pack_name(node)

  rg_exists = rg.check_existence(resource_group_name)

  if rg_exists
    all_nsgs_in_rg = nsg.list_security_groups(resource_group_name)
    unless all_nsgs_in_rg.empty?
      matched_nsgs = nsg.get_matching_nsgs(all_nsgs_in_rg, pack_name)
      unless matched_nsgs.empty?
        nsg_version = matched_nsgs.count
      end
    end
  else
    rg.add(resource_group_name, location)
  end

  network_security_group_name = Utils.get_network_security_group_name(node, nsg_version + 1)

  sec_rules = nsg.get_sec_rules_definition(node, network_security_group_name, resource_group_name)

  parameters = Fog::Network::AzureRM::NetworkSecurityGroup.new
  parameters.location = location
  parameters.security_rules = sec_rules

  # 3. Match the NSG rules to see if your customized NSG exists already or not
  unless matched_nsgs.empty?
    is_matched = nsg.match_nsg_rules(matched_nsgs, sec_rules)
    unless is_matched.nil?
      return
    end
  end

  nsg_result = nsg.create_update(resource_group_name, network_security_group_name, parameters)
  # send the name of NSG to compute workorder
  puts "***RESULT:net_sec_group_id=" + nsg_result.id

  if !nsg_result.nil?
    Chef::Log.info("The network security group has been created\n\rid: '#{nsg_result.id}'\n\r'#{nsg_result.location}'\n\r'#{nsg_result.name}'\n\r")
  else
    raise 'Error creating network security group'
  end
end
