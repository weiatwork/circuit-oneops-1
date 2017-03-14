#
# Cookbook Name:: hadoop-yarn-v1
# Recipe:: resourcemanager_stop
#
# Copyright 2016, @WalmartLabs
#
# All rights reserved - Do Not Redistribute
#

# stop resourcemanager
ruby_block "Stop hadoop-resourcemanager service" do
    block do
        Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
        shell_out!("service hadoop-resourcemanager stop ",
            :live_stream => Chef::Log::logger)
    end
end
