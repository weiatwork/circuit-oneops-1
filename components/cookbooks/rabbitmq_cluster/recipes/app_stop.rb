
ruby_block "app stop" do
	block do
		Chef::Log.info (`rabbitmqctl stop_app`)
	end
end
