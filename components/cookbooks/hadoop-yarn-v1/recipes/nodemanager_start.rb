#
# Cookbook Name:: hadoop-yarn-v1
# Recipe:: nodemanager_start
#
# Copyright 2016, @WalmartLabs
#
# All rights reserved - Do Not Redistribute
#

# start nodemanager
ruby_block "Start hadoop-nodemanager service" do
    block do
        Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
        shell_out!("service hadoop-nodemanager start ",
            :live_stream => Chef::Log::logger)
    end
end
