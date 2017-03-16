
ruby_block "cluster status" do
	block do
		Chef::Log.info (`rabbitmqctl cluster_status`)
	end
end
