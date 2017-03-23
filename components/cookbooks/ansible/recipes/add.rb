require 'yaml'
require 'tempfile'

%w(python-devel openssl-devel git).each do |p|
	package p do
		action :install
	end
end

roles = parse_url(node.workorder.rfcCi.ciAttributes.roles)
playbook = parse_url(node.workorder.rfcCi.ciAttributes.playbook)

unless node.workorder.rfcCi.ciAttributes.pip_proxy_config
  ruby_block "create pip proxy content" do
    block do
      Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
      conf = shell_out("echo \"#{node.workorder.rfcCi.ciAttributes.pip_proxy_content}\" > /etc/pip.conf")
    end
  end
end

cookbook_file "#{Chef::Config[:file_cache_path]}/get-pip.py" do
  source 'get-pip.py'
  mode "0644"
  not_if { ::File.exists?(node.python.pip_binary) }
end

execute "install-pip" do
  cwd Chef::Config[:file_cache_path]
  command <<-EOF
  #{node['python']['binary']} get-pip.py
  EOF
  not_if { ::File.exists?(node.python.pip_binary) }
end

version = node.workorder.rfcCi.ciAttributes.ansible_version

ansible_pip "ansible" do
	version version
	action :install
end

# create ansible roles directory
directory "/etc/ansible/roles" do
	recursive true
	action :create
end

template "/etc/ansible/hosts" do
	source "hosts.erb"
end

puts "***RESULT:ansible_version=#{version}"

# Let's install role
roles.each do |role|
  role_h = [{ 'src' => role[:url]}]
  role_h[0]['name'] = role[:query]['name'] if role[:query].has_key? 'name'
  role_h[0]['scm'] = role[:query]['scm'] if role[:query].has_key? 'scm'
  role_h[0]['version'] = role[:query].has_key?('version') ? role[:query]['version'] : 'master'

  puts "***** #{role_h.to_yaml}"

  filename = Dir::Tmpname.make_tmpname "#{Chef::Config['file_cache_path']}/ansible_role", nil
  # ansible-galaxy is quirky that it required extension to be .yml
  filename = "#{filename}.yml"

  file "#{filename}" do
    content "#{role_h.to_yaml.sub("---","")}"
  end

  ansible_galaxy "#{filename}" do
    action :install_file
  end

end
