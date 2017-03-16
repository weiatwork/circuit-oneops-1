
include_recipe "rabbitmq_cluster::app_stop" unless node.current_hostname == node.selected_hostname

ruby_block "joining #{node.current_hostname} with #{node.selected_hostname}" do
	block do
		execute_command "rabbitmqctl join_cluster rabbit@#{node.selected_hostname}"
	end
	not_if { node.current_hostname == node.selected_hostname }
end

include_recipe "rabbitmq_cluster::app_start"
