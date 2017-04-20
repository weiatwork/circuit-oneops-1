require 'win32/service'
windows_service = node['windowsservice']

package_name = windows_service.package_name
service_name = windows_service.service_name

physical_path = windows_service.cmd_path
package_path = ::File.join(physical_path, package_name)
repository_url = windows_service.repository_url
version = windows_service.version

if ::Win32::Service.exists?(service_name) && ::Win32::Service.status(service_name)['current_state'] == 'running'
  windows_service service_name do
    action :stop
  end
end

directory package_path do
  action :delete
  recursive true
end


version_option = (version == 'latest') ? '' : "-version #{version}"
nuget = "C:\\ProgramData\\chocolatey\\lib\\NuGet.CommandLine\\tools\\NuGet.exe"

oo_local_vars = node.workorder.payLoad.OO_LOCAL_VARS if node.workorder.payLoad.has_key?(:OO_LOCAL_VARS)

Array(oo_local_vars).each do |var|
  if var[:ciName] == "nuget_exe"
    nuget = "#{var[:ciAttributes][:value]}"
  end
end

powershell_script "Install #{package_name}" do
  code "#{nuget} install #{package_name} -source #{repository_url} #{version_option} -outputdirectory #{physical_path} -ExcludeVersion -NoCache"
end
