require 'yaml'
require 'tempfile'
require 'mixlib/shellout'

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

playbook_dir = Dir::Tmpname.make_tmpname "#{Chef::Config['file_cache_path']}/ansible_playbook", nil

shell = Mixlib::ShellOut.new("mkdir -p #{playbook_dir}", :live_stream => STDOUT)
shell.run_command
shell.error!

playbook_file = "#{playbook_dir}/playbook.yml"

if playbook.kind_of?(Array)
  # Currently we only support git
  if playbook[0][:query].has_key?('scm') && playbook[0][:query]['scm'].eql?('git')
    revision = playbook[0][:query].has_key?('branch') ? playbook[0][:query]['branch'] : 'master'
    git "#{playbook_dir}" do
      repository playbook[0][:url]
      revision revision
      action :sync
    end

    playbook_file = playbook[0][:query].has_key?('path') ? "#{playbook_dir}/#{playbook[0][:query]['path']}" : "#{playbook_dir}/playbook.yml"

  elsif playbook[0][:url].end_with?(".tar.gz")
    shell = Mixlib::ShellOut.new("cd #{playbook_dir} && curl \"#{playbook[0][:url]}\" | tar zxv")
    shell.run_command
    shell.error!
    playbook_file = playbook[0][:query].has_key?('path') ? "#{playbook_dir}/#{playbook[0][:query]['path']}" : "#{playbook_dir}/playbook.yml"
  end

  # Run playbook
  Chef::Log.info("Running playbook: #{playbook_file}")
  ansible_galaxy "#{playbook_file}" do
    action :run
  end

  # remove tempdir
  directory "#{playbook_dir}" do
    recursive true
    action :delete
    only_if { ::File.directory?(playbook_dir) }
  end

else
  # handle inline yaml support
  ansible_playbook = "#{playbook_dir}/playbook.yml"

  file "#{ansible_playbook}" do
    content playbook
  end

  ansible_galaxy "#{ansible_playbook}" do
    action :run
  end
end
