
ruby_block "app status" do
	block do
		Chef::Log.info (`rabbitmqctl status`)
	end
end
