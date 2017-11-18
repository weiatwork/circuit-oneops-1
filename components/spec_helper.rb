require 'serverspec'
require 'pathname'
require 'json'

if ENV['OS'] == 'Windows_NT'
  set :backend, :cmd
  # On Windows, set the target host's OS explicitly
  set :os, :family => 'windows'
  $node_wo = ::JSON.parse(File.read('c:\windows\temp\serverspec\node.json'))
else
  set :backend, :exec
  if !ENV['WORKORDER'].empty?
    $node_wo = ::JSON.parse(File.read(ENV['WORKORDER'].to_s))
  else
    $node_wo = ::JSON.parse(File.read('/tmp/serverspec/node.json'))
  end
end

set :path, '/sbin:/usr/local/sbin:/usr/sbin:$PATH' unless os[:family] == 'windows'

require 'chef'

#Create node object, add attributes from WO and Ohai
$node = Chef::Node.new()
ohai = Ohai::System.new()
filter = %w{fqdn machinename hostname platform platform_version os os_version}
ohai.all_plugins(filter)
$node.consume_external_attrs(ohai.data, $node_wo)
