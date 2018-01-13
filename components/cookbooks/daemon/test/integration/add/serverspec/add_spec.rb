is_windows = ENV['OS'] == 'Windows_NT'

CIRCUIT_PATH = "#{is_windows ? 'C:/Cygwin64' : ''}/home/oneops"
require "#{CIRCUIT_PATH}/circuit-oneops-1/components/spec_helper.rb"

service_name = $node['workorder']['rfcCi']['ciAttributes']['service_name']

describe service(service_name) do
  it { should be_running }
end