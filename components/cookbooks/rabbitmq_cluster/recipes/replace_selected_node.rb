
include_recipe "rabbitmq_cluster::app_stop"

directory "/tmp/ssh" do
	action :create
end

node.cloud_ids.each do |id|
	file "/tmp/ssh/key_file_#{id}" do
		content node.workorder.payLoad.RequiresKeys.select { |k| k[:ciName].split("-")[1] == id }[0][:ciAttributes][:private]
		mode 0600
	end

	ruby_block "ghost modify" do
		block do
			Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
			ip_addresses = node.workorder.payLoad.RequiresComputes.select { |c| c[:ciName].split("-")[1] == id }
			ip_addresses.each do |ip|
				ssh_cmd = "ssh -i /tmp/ssh/key_file_#{id} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@#{ip[:ciAttributes][:private_ip]} "
				ghost_cmd = "ghost modify #{node.current_hostname} #{node.current_ip}"
				execute_cmd = shell_out("#{ssh_cmd} \"#{ghost_cmd}\"", :live_stream => Chef::Log)
				Chef::Log.info "output is: #{execute_cmd.stdout}"
			end
		end
	end

	ruby_block "break cluster" do
		block do
			Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
			ip_addresses = node.workorder.payLoad.RequiresComputes.select { |c| c[:ciName].split("-")[1] == id }
			ip_addresses.each do |ip|
				ssh_cmd = "ssh -i /tmp/ssh/key_file_#{id} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@#{ip[:ciAttributes][:private_ip]} "
				break_cmd = "rabbitmqctl forget_cluster_node rabbit@#{node.current_hostname}"
				execute_cmd = shell_out("#{ssh_cmd} \"#{break_cmd}\"", :live_stream => Chef::Log)
				Chef::Log.info "output is: #{execute_cmd.stdout}"
			end
		end
	end
end

directory "/tmp/ssh" do
	recursive true
	action :delete
end

node.hostnames.each do |host|
	ruby_block "joining #{node.current_hostname} with #{host}" do
		block do
			execute_command "rabbitmqctl join_cluster rabbit@#{host}"
		end
		not_if { host == node.current_hostname }
	end
end

include_recipe "rabbitmq_cluster::app_start"
