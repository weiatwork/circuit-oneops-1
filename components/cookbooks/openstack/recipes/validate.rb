#
# openstack::status - gets quota info
# 

require 'fog'

token = node[:workorder][:ci][:ciAttributes]

begin
  conn = nil

  if compute_service[:endpoint].include?("v3")
    conn = Fog::Compute.new({
      :provider => 'OpenStack',
      :openstack_api_key => compute_service[:password],
      :openstack_username => compute_service[:username],
      :openstack_project_name => compute_service[:tenant],
      :openstack_domain_name => 'default',
      :openstack_auth_url => compute_service[:endpoint]
    })  
  else
    conn = Fog::Compute.new({
      :provider => 'OpenStack',
      :openstack_api_key => compute_service[:password],
      :openstack_username => compute_service[:username],
      :openstack_tenant => compute_service[:tenant],
      :openstack_auth_url => compute_service[:endpoint]
    })
  end

  Chef::Log.info("credentials ok")

rescue Exception => e
  Chef::Log.error("credentials bad: #{e.inspect}")
  e = Exception.new("no backtrace")
  e.set_backtrace("")
  raise e
end

