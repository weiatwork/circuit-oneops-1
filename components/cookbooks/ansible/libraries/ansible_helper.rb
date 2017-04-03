require 'psych'
require 'uri'
require 'fileutils'
include Chef::Mixin::ShellOut

# Install packages that ansible need
def install_packages()

	# Install packages that python required to install
	# package during runtime
	%w(python-devel openssl-devel git gcc).each do |p|
	  package p do
	    action :install
	  end
	end

  pip_file = "#{node.run_context.cookbook_collection["ansible"].root_paths.first}/files/default/get-pip.py"

  unless ::File.exists?("#{Chef::Config[:file_cache_path]}/get-pip.py")
    FileUtils.cp(pip_file,"#{Chef::Config[:file_cache_path]}/get-pip.py")
  end

	# Install only if pip is not present on the system
	unless ::File.exists?(node.python.pip_binary)
    shell = Mixlib::ShellOut.new("#{node['python']['binary']} #{Chef::Config[:file_cache_path]}/get-pip.py", :live_stream => STDOUT)
    shell.run_command
    shell.error!
  end

end

def configure_pip_config(content='')
	return false if content.empty?

	::File.open('/etc/pip.conf', 'w') do |file|
		file.puts content
	end

	return true
end

def install_ansible(version='latest')
	ansible_pip "ansible" do
		version version
		action :install
	end
end

def configure_ansible()
	FileUtils::mkdir_p '/etc/ansible/roles'

	::File.open('/etc/ansible/hosts', 'w') do |file|
		file.puts "localhost ansible_connection=local"
	end

  ansible_pip "retrying" do
    action :install
  end

end

def stage_playbook_dir(directory='')
	return false if directory.empty?

	# create working directory for playbook
	FileUtils::mkdir_p directory

  role_file = "#{node.run_context.cookbook_collection["ansible"].root_paths.first}/files/default/load_role.py"

  unless ::File.exists?("#{directory}/load_role.py")
    FileUtils.cp(role_file,"#{directory}/load_role.py")
  end

	return true
end

def parse_url(content=nil,multi=true)
  unless content.nil?
    # try to parse yaml content, if valid it is inline yaml,
    # return string untouch
    begin
      yml = Psych.load(content)

      if yml.kind_of?(String)
				parsed_urls = []
				begin
					content.each_line do |line|
						begin
							uri = URI.split(URI.escape(line))
							scheme = uri[0]
							user_info = uri[1].nil? ? '' : "#{uri[1]}@"
							host = uri[2]
							port = uri[3].nil? ? '' : ":#{uri[3]}"
							path = uri[5].nil? ? '' : uri[5]
							query = uri[7].nil? ? '' : URI.decode(uri[7])

							queries = query.split('&')

							query_hash = Hash.new

							queries.each do |q|
								(k,v) = q.split('=')
								query_hash[k] = v
							end

							if path.end_with? ".git"
								query_hash['scm'] = 'git'
							end

							url = "#{scheme}://#{user_info}#{host}#{port}#{path}"

							parsed_urls.push({:url => url,:query => query_hash})
							return parsed_urls
						rescue URI::InvalidURIError => e
							puts "**FAULT:FATAL=You've provided invalid URL: #{line}"
							_raise_exception()
						end
					end
				end
      elsif yml.kind_of?(Hash)
				return content
      elsif yml.nil?
				puts "***FAULT:FATAL=Your content is neither a valid YAML or a valid URL"
				_raise_exception()
      end
    rescue Psych::SyntaxError => e
			puts "***FAULT:FATAL=Your content is neither a valid YAML or a valid URL"
			_raise_exception()
    end
  end
end

def _raise_exception()
	e = Exception.new("no backtrace")
	e.set_backtrace("")
	raise e
end
