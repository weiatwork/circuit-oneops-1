
def execute_command(command)
	output = `#{command} 2>&1`
	if $?.success?
		Chef::Log.info("#{command} got successful. #{output.gsub(/\n+/, '.')}")
	else
        Chef::Log.warn("#{command} got failed. #{output.gsub(/\n+/, '.')}")
	end
end
