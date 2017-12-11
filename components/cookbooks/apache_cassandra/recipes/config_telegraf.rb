
depends_on = node.workorder.payLoad.DependsOn
telegraf = []
depends_on.each do |d|
  next if d[:ciClassName] != "bom.walmartlabs.Telegraf"
  next if !d.ciAttributes.has_key?("configure")
  config = d.ciAttributes.configure
  next if config =! nil && !config.empty?
  telegraf.push d
 end

if telegraf.empty?
  Chef::Log.info("Telegraf payload with empty config not found");
  return
end

telegraf_comp = telegraf[0]
last_part = telegraf_comp.ciName.split('-').last(2).join('-')
telegraf_name = telegraf_comp.ciName.chomp("-"+last_part)  
telegraf_service_name = "telegraf"+"_"+telegraf_name
 
tmp = Chef::Config[:file_cache_path]
services = node[:workorder][:services]
if services.nil?  || !services.has_key?(:maven)
  Chef::Log.error('Please make sure your cloud has Service nexus added. Pull the design to add nexux service.')
  exit 1
end

cloud_name = node[:workorder][:cloud][:ciName]
Chef::Log.info("Using cloud: #{cloud_name}")
cloud_services = services[:maven][cloud_name]

telegraf_artifact_url = cloud_services[:ciAttributes][:url] + "content/groups/public/com/walmart/strati/telegraf"

version=`curl -s #{telegraf_artifact_url}/maven-metadata.xml | grep latest `.gsub(/<latest>/,'<\1>')
version=version.gsub(/<\/latest>/,'<\1>')
version=version.gsub(/<>/,'').strip

Chef::Log.info("Telegraf config version : #{version}");

jar="telegraf-#{version}.jar"
telegraf_download_url="#{telegraf_artifact_url}/#{version}/#{jar}"
Chef::Log.info("telegraf_download_url : #{telegraf_download_url}")

source_list = [telegraf_download_url]

dest_file = "#{tmp}/#{jar}"
if node.workorder.has_key?("rfcCi")
   ci = node.workorder.rfcCi
   actionName = node.workorder.rfcCi.rfcAction
else
     ci = node.workorder.ci
     actionName = node.workorder.actionName
end
puts "source_list = #{source_list}"
if actionName == 'upgrade'
  # `curl -o #{dest_file} #{telegraf_download_url}`
else
  shared_download_http source_list.join(",") do
    path dest_file
    action :create
  end
end

execute "untar_telegraf_config" do
  command "jar xf #{dest_file}"
  cwd "#{tmp}"
end

#  run the template engine
execute 'Running Template' do
   command "source /etc/profile.d/oneops.sh;/usr/bin/config_template  #{tmp}/telegraf-cassandra.config > #{tmp}/telegraf.conf.2"
end

execute "copy_telegraf_config" do
  command "cp telegraf.conf.2 /etc/telegraf/telegraf.conf"
  cwd "#{tmp}"
end

ruby_block "stop #{telegraf_service_name}" do
    block do
      Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
      shell_out!("service #{telegraf_service_name} stop",
        :live_stream => Chef::Log::logger)
    end
end

ruby_block "start #{telegraf_service_name}" do
    block do
      Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
      shell_out!("service #{telegraf_service_name} start",
        :live_stream => Chef::Log::logger)
    end
end



