#Component-specific code
require 'chef'
require "#{$circuit_path}/circuit-oneops-1/components/cookbooks/volume/libraries/util.rb"

#Create node object, add attributes from WO and Ohai
$chef_node = Chef::Node.new()
ohai = Ohai::System.new()
filter = %w{fqdn machinename hostname platform platform_version os os_version}
ohai.all_plugins(filter)
$chef_node.consume_external_attrs(ohai.data, $node)

$storage,$device_map = get_storage($chef_node)

$ciAttr = $chef_node['workorder']['rfcCi']['ciAttributes']
$mount_point = $ciAttr['mount_point']
