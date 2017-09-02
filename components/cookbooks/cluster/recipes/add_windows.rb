Chef::Log.info("Configure windows cluster")

#limiting cluster name to 15 characters
platform_name = node[:workorder][:box][:ciName]
ciId_s = node[:workorder][:rfcCi][:ciId].to_s
id_length = ciId_s.to_s.length
cluster_name = platform_name[0..(15-id_length-7)] +'-clus-'+ ciId_s
puts "***RESULT:cluster_name=#{cluster_name}"

cloud = node[:workorder][:cloud][:ciName]
services = node[:workorder][:services]

if !services.has_key?('windows-domain')
  exit_with_error("No windows-domain service")
end

if !services.has_key?(:compute)
  exit_with_error("No compute service")
end

compute_service = services[:compute][cloud][:ciAttributes]
provider = services[:compute][cloud][:ciClassName].split('.').last

if provider !~ /Openstack/
  exit_with_error("Compute provider #{provider} is not currently supported")
end

#Get an array of computes in the cluster
computes = node[:workorder][:payLoad][:ManagedVia].map { |comp| {:instance_id => comp[:ciAttributes][:instance_id], :private_ip => comp[:ciAttributes][:private_ip] } }.uniq

#get nodes - using custom payload hostnames
if !node[:workorder][:payLoad].has_key?('hostnames')
  exit_with_error("No custom payload for hostnames was found")
end

fqdns = node[:workorder][:payLoad][:hostnames].select { |i| (i[:ciClassName] =~ /Fqdn/ && i[:ciAttributes].has_key?(:entries))}
entries = fqdns.map { |i| JSON.parse(i[:ciAttributes][:entries])}.uniq
a_records = entries.select {|i| i.values.first.any? {|v| v =~ /(\d+\.\d+\.\d+\.\d+)/}}
nodes = a_records.map { |i| i.keys.first.split('.').first }.uniq

if nodes.size != computes.size
  Chef::Log.error("Nodes: #{nodes.inspect}")
  exit_with_error("Number of DNS records (#{nodes.size}) does not match number of computes (#{computes.size})!")
end

#Create ip-addresses (ports) for all the subnets
require 'fog'

#Get a handle to Openstack compute service
compute_conn = Fog::Compute::OpenStack.new(
    :openstack_api_key  => compute_service[:password],
    :openstack_username => compute_service[:username],
    :openstack_tenant   => compute_service[:tenant],
    :openstack_auth_url => compute_service[:endpoint]
)

#Get a list of networks for all the computes
networks_from_vm = computes.map { |c| compute_conn.servers.get(c[:instance_id]).addresses.keys.first}.uniq

#Get a handle to Openstack network service
network_conn = Fog::Network::OpenStack.new(
    :openstack_api_key  => compute_service[:password],
    :openstack_username => compute_service[:username],
    :openstack_tenant   => compute_service[:tenant],
    :openstack_auth_url => compute_service[:endpoint]
)

#Get a list of networks in the cloud, that match the network list from the computes
networks_from_cloud = network_conn.networks.select{|n| ( networks_from_vm.include?(n.name) )}
ports = network_conn.ports.select{|p| ( p.name == cluster_name )}

#create a port for each network
cluster_ips = []
networks_from_cloud.each do |n|
  port = ports.select{|p| ( p.network_id == n.id )}
  if port.size == 0
    request = {:network_id => n.id,
               :name => cluster_name }

    response = network_conn.ports.create(request)
    cluster_ips.push(response.fixed_ips.first['ip_address'])
  else
    cluster_ips.push(port.first.fixed_ips.first['ip_address'])
  end
end

puts "***RESULT:shared_ip=#{cluster_ips.inspect}"
puts "***RESULT:dns_record=#{cluster_ips.join(',')}"

#create a cluster
ou = 'Servers'
ps_script = "#{Chef::Config[:file_cache_path]}\\cookbooks\\cluster\\files\\windows\\Create-Cluster.ps1"
arglist = "-cluster_name '#{cluster_name}' -node '#{nodes.join(',')}' -static_ip '#{cluster_ips.join(',')}' -ou '#{ou}'"
attr = services['windows-domain'][cloud][:ciAttributes]
svcacc_username = "#{attr[:domain]}\\#{attr[:username]}"
svcacc_password = attr[:password]

elevated_script 'Create-Cluster' do
  script ps_script
  timeout 300
  arglist arglist
  user svcacc_username
  password svcacc_password
  sensitive true
  guard_interpreter :powershell_script
  not_if 'try {get-cluster -ErrorAction Stop} catch {$false}'
end

