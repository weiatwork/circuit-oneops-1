
include_recipe "rabbitmq_cluster::app_stop" unless node.current_hostname == node.selected_hostname

execute "joining #{node.current_hostname} with #{node.selected_hostname}" do
	command "rabbitmqctl join_cluster rabbit@#{node.selected_hostname}"
	not_if { node.current_hostname == node.selected_hostname }
end

include_recipe "rabbitmq_cluster::app_start"
