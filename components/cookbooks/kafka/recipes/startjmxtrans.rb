`mkdir -p /var/run/transjmx && chown transjmx:transjmx /var/run/transjmx`

service "jmxtrans" do
  provider Chef::Provider::Service::Init
  service_name 'jmxtrans'
  supports  :restart => true, :status => true, :stop => true, :start => true
  action :start
end