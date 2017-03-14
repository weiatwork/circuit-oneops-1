#
# Cookbook Name:: hadoop-yarn-v1
# Recipe:: nodemanager_stop
#
# Copyright 2016, @WalmartLabs
#
# All rights reserved - Do Not Redistribute
#

# stop nodemanager
ruby_block "Stop hadoop-nodemanager service" do
    block do
        Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
        shell_out!("service hadoop-nodemanager stop ",
            :live_stream => Chef::Log::logger)
    end
end
