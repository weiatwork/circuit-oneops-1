
ruby_block "breaking #{node.current_hostname} from cluster #{node.selected_hostname}:#{node.selected_ip}" do
	block do
		Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
		ssh_cmd = "ssh -i /tmp/ssh/key_file_#{node.selected_cloud_id} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@#{node.selected_ip} "
		break_cmd = "rabbitmqctl forget_cluster_node rabbit@#{node.current_hostname}"
		execute_cmd = shell_out("#{ssh_cmd} \"#{break_cmd}\"", :live_stream => Chef::Log)
		Chef::Log.info "output is: #{execute_cmd.stdout}"
	end
end

include_recipe "rabbitmq_cluster::app_stop"

include_recipe "rabbitmq_cluster::join"
