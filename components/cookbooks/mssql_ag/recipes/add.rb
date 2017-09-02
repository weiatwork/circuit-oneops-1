#
# Cookbook:: mssql_ag
# Recipe:: default
#
# Copyright:: 2017, Oneops, All Rights Reserved.


#1. grant connect permissions
#2. create availability group (run on primary only)
#3. wait until availability group is created
#4. add listener object to AD (run on primary only)
#5. add listener to AG (run on primary only)
#6. join to availability group (for secondary nodes)

ag_name = node[:mssql_ag][:ag_name]
mssql = node[:workorder][:payLoad][:DependsOn].select {|m| (m.ciClassName.split('.').last == 'Mssql') }.first
port = mssql[:ciAttributes][:tcp_port]
mirroring_port = mssql[:ciAttributes][:mirroring_port]
failover_mode = 'AUTOMATIC'
availability_mode = 'SYNCHRONOUS_COMMIT'

sql_file = "#{Chef::Config[:file_cache_path]}/cookbooks/mssql_ag/files/windows/grant-permissions.sql"
cmd = "Invoke-Sqlcmd -InputFile \"#{sql_file}\" "

powershell_script 'grant-permissions' do
  code cmd
end

#Create availability group
sql_file = "#{Chef::Config[:file_cache_path]}/cookbooks/mssql_ag/files/windows/Create-AG.sql"
cmd = "
  $domain = (gwmi win32_computersystem).Domain
  $nodes = (get-clusternode).Name -Join ','
  $var = \"ag_name='#{ag_name}'\", \"tcp_port=#{port}\", \"mirroring_port=#{mirroring_port}\", \"domain='$domain'\", \"hostnames='$nodes'\", \"failover_mode='#{failover_mode}'\", \"availability_mode='#{availability_mode}'\"
  Invoke-Sqlcmd -InputFile \"#{sql_file}\" -Variable $var"

powershell_script 'Create-AG' do
  code cmd
  only_if "!(Get-ClusterGroup | Where-Object {$_.Name -eq '#{ag_name}'}) -and ((Get-ClusterGroup -Name 'Cluster Group').OwnerNode -eq $env:COMPUTERNAME)"
end

#wait until AG is created
ruby_block 'Wait-AG-Created' do
  block do

    ps_code = "Get-ClusterGroup | Where-Object {$_.Name -eq '#{ag_name}'}"
    start_time = Time.now.to_i
    i = 1
    ag_failed = true

    #try connecting for 150 seconds
    while Time.now.to_i - start_time < 150 do
      Chef::Log.info( "Attempt:#{i} Checking if availability group #{ag_name} is created ...")
      rc = powershell_out!(ps_code)

      if !rc.stderr.nil? && !rc.stderr.empty?
        exit_with_error (rc.stderr)
      end

      if !rc.stdout.nil? && !rc.stdout.empty?
        ag_failed = false
        Chef::Log.info( "Availability group #{ag_name} is created! Moving on to a next step...")
        break
      end

      Chef::Log.info( "Availability group #{ag_name} is not created yet. Waiting...")
      sleep 10
      i += 1
    end #while

    if ag_failed
      exit_with_error("Availability group #{ag_name} has not been created in 150 seconds")
    end

  end
end



#create AD object for listener - on primary replica
listener_name = node[:workorder][:payLoad][:ag_lb][0][:ciName]
listener_ip = node[:workorder][:payLoad][:ag_lb][0][:ciAttributes]['dns_record']
cluster_name = node[:workorder][:payLoad][:ag_cluster][0][:ciAttributes][:cluster_name]
nodes = node[:workorder][:payLoad][:ag_os].map{|o| o[:ciAttributes][:hostname]}

ou = 'Servers'
ps_script = "#{Chef::Config[:file_cache_path]}\\cookbooks\\mssql_ag\\files\\windows\\Create-ListenerADObject.ps1"
arglist = "-listener_name '#{listener_name}' -cluster_name '#{cluster_name}' -node '#{nodes.join(',')}' -ou '#{ou}'"
cloud = node[:workorder][:cloud][:ciName]
attr = node[:workorder][:services]['windows-domain'][cloud][:ciAttributes]
svcacc_username = "#{attr[:domain]}\\#{attr[:username]}"
svcacc_password = attr[:password]

elevated_script 'Create-ListenerADObject' do
  script ps_script
  timeout 300
  arglist arglist
  user svcacc_username
  password svcacc_password
  sensitive true
  guard_interpreter :powershell_script
  only_if "(Get-ClusterGroup -Name '#{ag_name}').OwnerNode -eq $env:COMPUTERNAME"
end



#Add listener to AG - on primary replica
sqlcmd = "ALTER AVAILABILITY GROUP [#{ag_name}] ADD LISTENER N'#{listener_name}' (WITH IP ((N'#{listener_ip}',N'255.255.255.255')), PORT = #{port});"
cmd = "Invoke-Sqlcmd -Query \"#{sqlcmd}\" "

#TO-DO Listener won't add to the cluster as LB IP belongs to a different subnet
powershell_script 'Add-ListenerToAG' do
  code cmd
  only_if "(Get-ClusterGroup -Name '#{ag_name}').OwnerNode -eq $env:COMPUTERNAME"
  action :nothing
end



#Join secondary replicas to AG
sqlcmd = "ALTER AVAILABILITY GROUP [#{ag_name}] JOIN;"
cmd = "Invoke-Sqlcmd -Query \"#{sqlcmd}\" "

powershell_script 'Join-AG' do
  code cmd
  only_if "(Get-ClusterGroup -Name '#{ag_name}').OwnerNode -ne $env:COMPUTERNAME"
  not_if "((Get-Clusterownernode -Group '#{ag_name}').OwnerNodes | Where-Object {$_.Name -eq $env:COMPUTERNAME}) -ne $empty"
end
