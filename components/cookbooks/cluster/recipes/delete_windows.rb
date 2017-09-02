require 'fog'

Chef::Log.info("Destroying windows cluster")
ou = 'Servers'
cluster_ips = node[:workorder][:rfcCi][:ciAttributes][:shared_ip]
ps_script = "#{Chef::Config[:file_cache_path]}\\cookbooks\\cluster\\files\\windows\\Destroy-Cluster.ps1"
arglist = "-ou '#{ou}'"

cloud = node[:workorder][:cloud][:ciName]
services = node[:workorder][:services]

if !services.has_key?('windows-domain') 
  exit_with_error("No windows-domain service")
end

if !services.has_key?(:compute) 
  exit_with_error("No compute service")
end

compute_service = services[:compute][cloud][:ciAttributes]
attr = services['windows-domain'][cloud][:ciAttributes]
svcacc_username = "#{attr[:domain]}\\#{attr[:username]}"
svcacc_password = attr[:password]

elevated_script 'Destroy-Cluster' do
  script ps_script
  timeout 300
  arglist arglist
  user svcacc_username
  password svcacc_password
  sensitive true
  guard_interpreter :powershell_script
  only_if 'try {get-cluster -ErrorAction Stop;$true} catch {$false}'
end


#Delete cluster ip-addresses 
require 'fog'

#Get a handle to Openstack network service
network_conn = Fog::Network::OpenStack.new(
    :openstack_api_key  => compute_service[:password],
    :openstack_username => compute_service[:username],
    :openstack_tenant   => compute_service[:tenant],
    :openstack_auth_url => compute_service[:endpoint]
)

#remove ports
ports = network_conn.ports

ports = network_conn.ports.select{|p| ( cluster_ips.include?(p.fixed_ips.first['ip_address']) )}
ports.each do |p|
  response = network_conn.ports.get(p.id).destroy
  puts response.request
end