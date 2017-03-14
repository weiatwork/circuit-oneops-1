#
# Cookbook Name:: hadoop-yarn-v1
# Recipe:: nodemanager_restart
#
# Copyright 2016, @WalmartLabs
#
# All rights reserved - Do Not Redistribute
#

include_recipe "hadoop-yarn-v1::nodemanager_stop"
include_recipe "hadoop-yarn-v1::nodemanager_start"
