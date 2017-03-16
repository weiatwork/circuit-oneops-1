
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
end

ruby_block "breaking #{node.current_hostname} from cluster #{node.selected_hostname}:#{node.selected_ip}" do
	block do
		Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
		ssh_cmd = "ssh -i /tmp/ssh/key_file_#{node.selected_cloud_id} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@#{node.selected_ip} "
		break_cmd = "rabbitmqctl forget_cluster_node rabbit@#{node.current_hostname}"
		execute_cmd = shell_out("#{ssh_cmd} \"#{break_cmd}\"", :live_stream => Chef::Log)
		Chef::Log.info "output is: #{execute_cmd.stdout}"
	end
end

directory "/tmp/ssh" do
	recursive true
	action :delete
end

include_recipe "rabbitmq_cluster::app_stop"

include_recipe "rabbitmq_cluster::join"
