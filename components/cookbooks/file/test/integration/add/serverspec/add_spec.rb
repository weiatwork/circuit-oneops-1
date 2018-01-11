is_windows = ENV['OS'] == 'Windows_NT'

CIRCUIT_PATH = "#{is_windows ? 'C:/Cygwin64' : ''}/home/oneops"
require "#{CIRCUIT_PATH}/circuit-oneops-1/components/spec_helper.rb"

describe file($node['workorder']['rfcCi']['ciAttributes']['path']) do
  it { should be_file }
end

describe file($node['workorder']['rfcCi']['ciAttributes']['path']) do
  it { should exist }
end

describe file(File.dirname($node['workorder']['rfcCi']['ciAttributes']['path'])) do
  it { should be_directory }
end

describe file($node['workorder']['rfcCi']['ciAttributes']['path']) do
  it { should contain $node['workorder']['rfcCi']['ciAttributes']['content'] }
end

describe file($node['workorder']['rfcCi']['ciAttributes']['path']) do
  it { should be_mode 755 }
end

describe file($node['workorder']['rfcCi']['ciAttributes']['path']) do
  it { should be_owned_by 'root' }
end

describe file($node['workorder']['rfcCi']['ciAttributes']['path']) do
  it { should be_grouped_into 'root' }
end

describe file($node['workorder']['rfcCi']['ciAttributes']['path']) do
  it { should be_readable }
end

describe file($node['workorder']['rfcCi']['ciAttributes']['path']) do
  it { should contain $node['workorder']['rfcCi']['ciAttributes']['content'] }
end