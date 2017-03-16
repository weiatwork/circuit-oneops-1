
ruby_block "app start" do
	block do
		Chef::Log.info (`rabbitmqctl start_app`)
	end
end
