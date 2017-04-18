include_recipe 'windowsservice::install_nuget_package'

windows_service = node['windowsservice']

if windows_service.user_account == 'SpecificUser'
  if !windows_service.username.include?('\\')
    user_name = ".\\#{windows_service.username}"
  else
    user_name = windows_service.username
  end
else
  user_name = windows_service.user_account
end

version = windows_service.package_version
package_name = windows_service.package_name
windows_service_path = "#{windows_service.cmd_path}\\#{package_name}.#{version}\\#{windows_service.path}"

if windows_service.service_display_name.nil? || windows_service.service_display_name.empty?
  win_service_display_name = windows_service.service_name
else
  win_service_display_name = windows_service.service_display_name
end

service_action = ( node[:workorder][:rfcCi][:rfcAction] == 'update' ) ? :update : :create

windowsservice windows_service.service_name do
  action service_action
  service_name windows_service.service_name
  service_display_name win_service_display_name
  path windows_service_path
  startup_type windows_service.startup_type
  username user_name
  password windows_service.password
end

include_recipe 'windowsservice::start_service'
