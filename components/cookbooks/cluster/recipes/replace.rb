Chef::Log.info("Cluster replace called.")

include_recipe "cluster::delete"
include_recipe "cluster::add"
