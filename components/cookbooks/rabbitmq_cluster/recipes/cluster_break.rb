
include_recipe "rabbitmq_cluster::app_stop"
include_recipe "rabbitmq_cluster::reset"
include_recipe "rabbitmq_cluster::app_start"
