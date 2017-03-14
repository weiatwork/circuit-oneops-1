#
# Cookbook Name:: hadoop-yarn-v1
# Recipe:: namenode_stop
#
# Copyright 2016, @WalmartLabs
#
# All rights reserved - Do Not Redistribute
#

# stop namenode
ruby_block "Stop hadoop-namenode service" do
    block do
        Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
        shell_out!("service hadoop-namenode stop ",
            :live_stream => Chef::Log::logger)
    end
end
