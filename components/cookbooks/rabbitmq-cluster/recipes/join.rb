
ruby_block "stop app" do
	block do
		execute_command "rabbitmqctl stop_app"
	end
	not_if { node.current_hostname == node.selected_hostname }
end

ruby_block "joining #{node.current_hostname} with #{node.selected_hostname}" do
	block do
		execute_command "rabbitmqctl join_cluster rabbit@#{node.selected_hostname}"
	end
	not_if { node.current_hostname == node.selected_hostname }
end

ruby_block "start app" do
	block do
		execute_command "rabbitmqctl start_app"
	end
end
