service 'kafka-rest' do
  provider Chef::Provider::Service::Systemd
  service_name 'kafka-rest'
  supports  :restart => true, :status => true, :stop => true, :start => true
  action :start
end