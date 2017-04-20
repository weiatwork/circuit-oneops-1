version = node.windowsservice.version
package_name = node.windowsservice.package_name
repository_url = node.windowsservice.repository_url

if version == 'latest'
  cmd = Mixlib::ShellOut.new("nuget list #{package_name} -source #{repository_url}")
  cmd.run_command
  version = cmd.stdout.split('\n')
  Chef::Log.fatal "The given package #{package_name} does not exist" unless version.size == 1
  version = version[ 0 ].split(' ')[ 1 ]
end

Chef::Log.info "Package version: #{version}"

node.set['windowsservice']['package_version'] = version
