
def exit_with_error(msg)
	puts "***FAULT:FATAL=#{msg}"
	Chef::Application.fatal!(msg)
end

def execute_command(command)
	output = `#{command} 2>&1`
	if $?.success?
		Chef::Log.info("#{command} got successful.. #{output.gsub(/\s+/, " ")}")
	else
        exit_with_error "#{command} got failed.. #{output.gsub(/\s+/, " ")}"
	end
end
