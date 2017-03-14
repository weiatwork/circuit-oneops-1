#
# Cookbook Name:: hadoop-yarn-v1
# Recipe:: secondarynamenode_start
#
# Copyright 2016, @WalmartLabs
#
# All rights reserved - Do Not Redistribute
#

# start secondarynamenode
ruby_block "Start hadoop-secondarynamenode service" do
    block do
        Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
        shell_out!("service hadoop-secondarynamenode start ",
            :live_stream => Chef::Log::logger)
    end
end
