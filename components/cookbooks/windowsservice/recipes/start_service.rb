windows_service = node['windowsservice']

windowsservice windows_service.service_name do
  action :start
  arguments JSON.parse(windows_service.arguments)
end
