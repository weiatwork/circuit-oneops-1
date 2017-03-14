#
# Cookbook Name:: hadoop-yarn-v1
# Recipe:: resourcemanager_start
#
# Copyright 2016, @WalmartLabs
#
# All rights reserved - Do Not Redistribute
#

# start resourcemanager
ruby_block "Start hadoop-resourcemanager service" do
    block do
        Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
        shell_out!("service hadoop-resourcemanager start ",
            :live_stream => Chef::Log::logger)
    end
end
