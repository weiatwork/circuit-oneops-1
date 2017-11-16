$circuit_path = '/home/oneops'
require "#{$circuit_path}/circuit-oneops-1/components/spec_helper.rb"
require "#{$circuit_path}/circuit-oneops-1/components/cookbooks/volume/test/integration/volume_helper.rb"

describe file($mount_point) do
 it { should_not be_mounted }
end

#assert each storage device from the map - a service file needs to exist in /opt/oneops/storage_devices
$device_map.each do |dev|
  if dev.split(':').size > 2
    resource_group_name, storage_account_name, ciID, slice_size, dev_id = dev.split(':')
    vol_id = [ciID, 'datadisk',dev.split('/').last.to_s].join('-')
  else
    vol_id, dev_id = dev.split(":")
  end

  reg = Regexp.new( "^#{Regexp.escape(dev_id)}:$" )

  describe file("/opt/oneops/storage_devices/#{vol_id}") do
    it { should be_file }
    its(:content) {should match reg}
  end

end if $storage