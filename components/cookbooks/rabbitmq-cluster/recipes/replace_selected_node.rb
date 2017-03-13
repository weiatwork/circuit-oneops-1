
ruby_block "stop app" do
	block do
		execute_command "rabbitmqctl stop_app"
	end
end

node.hostnames.each do |host|
	ruby_block "joining #{node.current_hostname} with #{host}" do
		block do
			execute_command "rabbitmqctl join_cluster rabbit@#{host}"
		end
	end
end

ruby_block "start app" do
	block do
		execute_command "rabbitmqctl start_app"
	end
end
