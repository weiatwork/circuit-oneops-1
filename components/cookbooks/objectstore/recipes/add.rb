cloud_name = node[:workorder][:cloud][:ciName]
cloud_type = node[:workorder][:services][:filestore][cloud_name][:ciClassName].split('.').last.downcase
ciAttr = node[:workorder][:rfcCi][:ciAttributes]

domain = ciAttr.key('domain') ? ciAttr[:domain] : 'default'
auth_url = ciAttr[:endpoint].include?('tokens') ? ciAttr[:endpoint] : "#{ciAttr[:endpoint]}/tokens"

case cloud_type
when /swift/
  creds = {
    :provider           => 'OpenStack',
    :openstack_api_key  => ciAttr[:password],
    :openstack_username => ciAttr[:username],
    :openstack_tenant   => ciAttr[:tenant],
    :openstack_auth_url => auth_url,
    :openstack_region   => ciAttr[:regionname],
    :openstack_project_name => ciAttr[:tenant],
    :openstack_domain_name => domain
  }
when /azureobjectstore/
  creds = {
    :provider                   => 'Azure',
    :storage_account_id         => ciAttr[:storage_account_id],
    :tenant_id                  => ciAttr[:tenant_id],
    :client_id                  => ciAttr[:client_id],
    :client_secret              => ciAttr[:client_secret]
  }
end

require 'json'
file '/etc/objectstore_creds.json' do
  content creds.to_json
end

cookbook_file 'objectstore' do
  mode '0755'
  path '/usr/local/bin/objectstore'
end

execute 'fix_dependency' do
  command 'gem uninstall fog-profitbricks -v 2.0.1 ; true'
  action :run
end
