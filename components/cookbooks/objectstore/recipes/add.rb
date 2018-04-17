cloud_name = node[:workorder][:cloud][:ciName]
cloud_type = node[:workorder][:services][:filestore][cloud_name][:ciClassName].split('.').last.downcase
ci_attr = node[:workorder][:rfcCi][:ciAttributes]

case cloud_type
when /swift/
  ci_attr_cloud = node[:workorder][:services][:filestore][cloud_name][:ciAttributes]
  domain = ci_attr_cloud.key('domain') ? ci_attr_cloud[:domain] : 'default'
  auth_url = ci_attr_cloud[:endpoint].include?('tokens') ? ci_attr_cloud[:endpoint] : "#{ci_attr_cloud[:endpoint]}/tokens"
  config = {
    :provider           => 'OpenStack',
    :openstack_api_key  => ci_attr_cloud[:password],
    :openstack_username => ci_attr_cloud[:username],
    :openstack_tenant   => ci_attr_cloud[:tenant],
    :openstack_auth_url => auth_url,
    :openstack_region   => ci_attr[:storage],
    :openstack_project_name => ci_attr_cloud[:tenant],
    :openstack_domain_name => domain
  }
when /azureobjectstore/
  config = {
    :provider                   => 'Azure',
    :storage_account_id         => ci_attr[:storage]
  }
end
  
require 'json'
file '/etc/objectstore_config.json' do
  content config.to_json
end

cookbook_file 'objectstore' do
  mode '0755'
  path '/usr/local/bin/objectstore'
end

execute 'fix_dependency' do
  command 'gem uninstall fog-profitbricks -v 2.0.1 ; true'
  action :run
end
