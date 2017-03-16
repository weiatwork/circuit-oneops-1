
ruby_block "node reset" do
	block do
		Chef::Log.info (`rabbitmqctl force_reset`)
	end
end
