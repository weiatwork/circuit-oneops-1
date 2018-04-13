cloud_name = node[:workorder][:cloud][:ciName]
cloud_type = node[:workorder][:services][:filestore][cloud_name][:ciClassName].split('.').last.downcase
ci_attr = node[:workorder][:rfcCi][:ciAttributes]

case cloud_type
when /swift/
  config = {
    :provider           => 'OpenStack',
    :openstack_region   => ci_attr_cloud[:storage]
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
