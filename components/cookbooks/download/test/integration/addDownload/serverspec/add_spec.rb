require 'spec_helper'

describe file($node['workorder']['rfcCi']['ciAttributes']['path']) do
  it { should be_file }
end

describe file($node['workorder']['rfcCi']['ciAttributes']['path']) do
  it { should exist }
end

describe file($node['workorder']['rfcCi']['ciAttributes']['path']) do
  it { should be_owned_by 'root' }
end

describe file($node['workorder']['rfcCi']['ciAttributes']['path']) do
  it { should be_grouped_into 'root' }
end