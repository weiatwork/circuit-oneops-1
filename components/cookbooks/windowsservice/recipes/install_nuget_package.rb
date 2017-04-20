require 'win32/service'

include_recipe 'windowsservice::default'

windows_service = node['windowsservice']
package_name = windows_service.package_name
service_name = windows_service.service_name

repository_url = windows_service.repository_url
version = windows_service.package_version

package_path = "#{windows_service.cmd_path}\\#{package_name}.#{version}"

if Dir.exist? package_path
  Chef::Log.info "The package #{package_name} already exists at #{package_path}"
  return
end

windows_service service_name do
  action :stop
  only_if { ::Win32::Service.exists?(service_name) && ::Win32::Service.status(service_name)['current_state'] == 'running' }
end

if Dir.exist? windows_service.cmd_path
  Dir.entries("#{windows_service.cmd_path}").each do |path|
    dir_path = "#{windows_service.cmd_path}//#{path}"
    directory dir_path do
      action :delete
      recursive true
      only_if { path.start_with?(package_name) }
    end
  end
end

version_option = "-version #{version}"
nuget = "C:\\ProgramData\\chocolatey\\lib\\NuGet.CommandLine\\tools\\NuGet.exe"

oo_local_vars = node.workorder.payLoad.OO_LOCAL_VARS if node.workorder.payLoad.has_key?(:OO_LOCAL_VARS)

Array(oo_local_vars).each do |var|
  if var[:ciName] == "nuget_exe"
    nuget = "#{var[:ciAttributes][:value]}"
  end
end

powershell_script "Install #{package_name}" do
  code "#{nuget} install #{package_name} -source #{repository_url} #{version_option} -outputdirectory #{windows_service.cmd_path} -NoCache"
end
