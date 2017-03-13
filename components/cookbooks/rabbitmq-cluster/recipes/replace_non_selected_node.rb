

puuid = (0..32).to_a.map{|a| rand(32).to_s(32)}.join
node.set[:ssh_key_file] = "/tmp/"+puuid

file node.ssh_key_file do
	content node.workorder.payLoad[:SecuredBy][0][:ciAttributes][:private]
	mode 0600
end

ruby_block "stop app" do
	block do
		execute_command "rabbitmqctl stop_app"
	end
end

ruby_block "breaking #{node.current_hostname} from cluster #{node.selected_hostname}:#{node.selected_ip}" do
	block do
		Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
		ssh_cmd = "ssh -i #{node.ssh_key_file} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@#{node.selected_ip} "
		forget_cmd = "rabbitmqctl forget_cluster_node #{node.current_hostname}"
		full_cmd = shell_out("#{ssh_cmd} \"#{forget_cmd}\"")
		puts full_cmd.stdout
	end
end

file node.ssh_key_file do
	action :delete
end

include_recipe "rabbitmq-cluster::join"
