require 'tempfile'

unless node.workorder.rfcCi.ciAttributes.pip_proxy_content.empty?
  unless configure_pip_config(node.workorder.rfcCi.ciAttributes.pip_proxy_content)
    puts "***FAULT:FATAL=Fail to config pip.conf file"
    Chef::Log.fatal("Fail to configure pip.conf file")
  end
end

install_packages()
version = node.workorder.rfcCi.ciAttributes.ansible_version
install_ansible(version)
configure_ansible()

playbook_dir = Dir::Tmpname.make_tmpname "#{Chef::Config['file_cache_path']}/ansible_playbook", nil

unless stage_playbook_dir(playbook_dir)
  puts "***FAULT:FATAL=Failed to configure playbook dir"
  Chef::Log.fatal("Failed to configure playbook dir")
end

playbook = parse_url(node.workorder.rfcCi.ciAttributes.playbook)

playbook_file = "#{playbook_dir}/playbook.yml"

if playbook.kind_of?(Array)
  # Currently we only support git
  if playbook[0][:query].has_key?('scm') && playbook[0][:query]['scm'].eql?('git')
    Chef::Log.info("Installing role from git repo")
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

  # If file is packaged with requirements.yml then install them
  # first.
  if ::File.exist?("{playbook_dir}/requirements.yml")
    ansible_galaxy "{playbook_dir}/requirements.yml" do
      action :install_file
    end
  else
    # run the role loader
    shell = Mixlib::ShellOut.new("#{node['python']['binary']} #{playbook_dir}/load_role.py -f #{playbook_file}", :live_stream => STDOUT)
    shell.run_command
    shell.error!
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
    content node.workorder.rfcCi.ciAttributes.playbook
  end

  ::File.open('/etc/pip.conf', 'w') do |file|
    file.puts playbook
  end

  # run the role loader
  shell = Mixlib::ShellOut.new("#{node['python']['binary']} #{playbook_dir}/load_role.py  -f #{ansible_playbook}", :live_stream => STDOUT)
  shell.run_command
  shell.error!

  ansible_galaxy "#{ansible_playbook}" do
    action :run
  end
