
node.set[:current_hostname] = node.workorder.payLoad.DependsOn.select { |c| c["ciClassName"] =~ /Os/}[0]["ciAttributes"]["hostname"]

computes = node.workorder.payLoad.RequiresComputes

return "not joining to cluster as total number of computes are 1 only.. exiting" if computes.size == 1

hostnames = Array.new
hostnames_ips = Hash.new

node.workorder.payLoad.hosts.each do |c|
	hostnames.push(c[:ciAttributes][:hostname])
end
node.set[:hostnames] = hostnames
node.set[:selected_hostname] = node.hostnames.min

hostnames.each do |h|
	ip = computes.select { |c| h.include?("#{c[:ciName].gsub('compute-','')}") }[0][:ciAttributes][:private_ip]
	hostnames_ips["#{ip}"] = h
end

node.set[:selected_ip] = hostnames_ips.select { |ip, host| host == node.selected_hostname }.keys[0]

ruby_block "adding hostname entries" do
	block do
		hostnames_ips.each do |ip, host|
			execute_command "ghost modify #{host} #{ip}"
		end
	end
end

Chef::Log.info("current_hostname: #{node.current_hostname}")
Chef::Log.info("selected_hostname: #{node.selected_hostname}")
Chef::Log.info("selected_ip: #{node.selected_ip}")
Chef::Log.info("hostnames_ips: #{hostnames_ips.inspect}")
