#Component-specific code
require 'chefspec'

fauxhai = `gem path fauxhai`.chop

RSpec.configure do |config|
  config.cookbook_path = "#{$circuit_path}/shared/cookbooks"
  config.path = "#{fauxhai}/lib/fauxhai/platforms/centos/7.2.1511.json"
  config.platform = 'centos'
  config.version = '7.2.1511'
end

chef = ChefSpec::SoloRunner.new()
chef.node.consume_attributes($node)
chef.converge('recipe[shared::set_provider_new]')
$chef_node = chef.node
$storage_provider_class = $chef_node['storage_provider_class']
$storage_provider = $chef_node['storage_provider']

if $storage_provider_class =~ /azuredatadisk/
  Dir["#{$circuit_path}/circuit-oneops-1/components/cookbooks/azure_base/libraries/*.rb"].each {|file| require file }
  Utils.set_proxy($chef_node['workorder']['payLoad']['OO_CLOUD_VARS'])
  $resource_group_name = AzureBase::ResourceGroupManager.new($chef_node).rg_name
  $storage_service = $storage_provider.instance_variable_get('@storage_service')
end