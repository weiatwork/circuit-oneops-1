is_windows = ENV['OS'] == 'Windows_NT'

CIRCUIT_PATH = "#{is_windows ? 'C:/Cygwin64' : ''}/home/oneops"
require "#{CIRCUIT_PATH}/circuit-oneops-1/components/spec_helper.rb"

comm = "ls "+$node['workorder']['rfcCi']['ciAttributes']['path']
puts comm
describe command(comm) do
  its(:stderr) { should match /No such file or directory/ }
end