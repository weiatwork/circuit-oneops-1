windows_service = node['windowsservice']
service_arguments = ( windows_service.arguments.empty? || windows_service.arguments.nil? ) ? nil : windows_service.arguments

windowsservice windows_service.service_name do
  action :start
  arguments service_arguments
end
