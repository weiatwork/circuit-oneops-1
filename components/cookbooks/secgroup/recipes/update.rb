#
# Cookbook Name:: secgroup
# Recipe:: update
#
cloud_name = node['workorder']['cloud']['ciName']
provider = node[:workorder][:services][:compute][cloud_name][:ciClassName].downcase
if provider =~ /azure/ && cloud_name =~ %r/\S+-wm-nc/
  include_recipe 'azuresecgroup::update_secgroup'
else
  include_recipe 'secgroup::add'
end

