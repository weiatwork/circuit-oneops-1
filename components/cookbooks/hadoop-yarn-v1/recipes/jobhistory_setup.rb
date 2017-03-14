#
# Cookbook Name:: hadoop-yarn-v1
# Recipe:: jobhistory_setup
#
# Copyright 2016, @WalmartLabs
#
# All rights reserved - Do Not Redistribute
#

# deploy jobhistory init script
cookbook_file "/etc/init.d/hadoop-jobhistory" do
    source "hadoop-jobhistory.init"
    owner 'root'
    group 'root'
    mode '0755'
end

# add jobhistory to chkconfig and start service
service "hadoop-jobhistory" do
    action [:enable, :start]
    supports :restart => true, :reload => true
end
