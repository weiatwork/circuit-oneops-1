#
# Cookbook Name:: hadoop-yarn-v1
# Recipe:: datanode_start
#
# Copyright 2016, @WalmartLabs
#
# All rights reserved - Do Not Redistribute
#

# start datanode
ruby_block "Start hadoop-datanode service" do
    block do
        Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
        shell_out!("service hadoop-datanode start ",
            :live_stream => Chef::Log::logger)
    end
end
