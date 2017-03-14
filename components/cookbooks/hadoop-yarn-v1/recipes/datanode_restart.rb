#
# Cookbook Name:: hadoop-yarn-v1
# Recipe:: datanode_restart
#
# Copyright 2016, @WalmartLabs
#
# All rights reserved - Do Not Redistribute
#

include_recipe "hadoop-yarn-v1::datanode_stop"
include_recipe "hadoop-yarn-v1::datanode_start"
