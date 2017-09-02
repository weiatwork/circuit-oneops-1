#
# Cookbook:: mssql_ag
# Recipe:: default
#
# Copyright:: 2017, Oneops, All Rights Reserved.

#Delete AD object for listener - on primary replica
listener_name = node[:workorder][:payLoad][:ag_lb][0][:ciName]
listener_ip = node[:workorder][:payLoad][:ag_lb][0][:ciAttributes]['dns_record']
cluster_name = node[:workorder][:payLoad][:ag_cluster][0][:ciAttributes][:cluster_name]
nodes = node[:workorder][:payLoad][:ag_os].map{|o| o[:ciAttributes][:hostname]}

ou = 'Servers'
ps_script = "#{Chef::Config[:file_cache_path]}\\cookbooks\\mssql_ag\\files\\windows\\Delete-ListenerADObject.ps1"
arglist = "-listener_name '#{listener_name}' -ou '#{ou}'"
cloud = node[:workorder][:cloud][:ciName]
attr = node[:workorder][:services]['windows-domain'][cloud][:ciAttributes]
svcacc_username = "#{attr[:domain]}\\#{attr[:username]}"
svcacc_password = attr[:password]

elevated_script 'Delete-ListenerADObject' do
  script ps_script
  timeout 300
  arglist arglist
  user svcacc_username
  password svcacc_password
  sensitive true
end