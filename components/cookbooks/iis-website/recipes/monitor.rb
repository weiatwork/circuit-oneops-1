%w(web_connections iis_service_status).each do | script_file_name |
  template "C:\\cygwin64\\opt\\nagios\\libexec\\#{script_file_name}.ps1" do
    source "#{script_file_name}.ps1.erb"
    variables({
        :site_name  => node.workorder.box.ciName
    })
  end
end
=begin

template "C:\\cygwin64\\opt\\nagios\\libexec\\web_connections.ps1" do
  source "web_connections.ps1.erb"
  variables({
      :site_name  => node.workorder.box.ciName
  })
end

template "/opt/nagios/libexec/iis_service_status.ps1" do
  source "iis_service_status.ps1.erb"
end

=end
