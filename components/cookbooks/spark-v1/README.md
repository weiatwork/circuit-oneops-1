Spark Cookbook (RC8 Build)
==========================

This cookbook deploys a Spark standalone cluster.  This cluster can then
be used to access a Cassandra cluster or some other data store.

Usage
-----

To use the pack, add it to your assembly.  Configure the Spark version
to install, and deploy.

Attributes
----------

* `default['spark-vrc8']['spark_version']` - The version of Spark to install.
* `default['spark-vrc8']['worker_cores']` - The number of cores available to each worker
* `default['spark-vrc8']['worker_memory']` - The amount of memory available to each worker
* `default['spark-vrc8']['master_opts']` - JVM options to pass to the Spark master
* `default['spark-vrc8']['worker_opts']` - JVM options to pass to the Spark worker
* `default['spark-vrc8']['spark_config']` - Additional values to set in the Spark configuration (spark-defaults.conf)
* `default['spark-vrc8']['spark_download_location']` - The type of download for Spark (nexus/custom)
* `default['spark-vrc8']['spark_custom_download']` - The URL to download a custom version from.
* `default['spark-vrc8']['enable_ganglia']` - Whether to enable Ganglia integration.
* `default['spark-vrc8']['ganglia_servers']` - The servers that Ganglia information should be passed to (expressed as server1:port1 server2:port2, etc).
* `default['spark-vrc8']['enable_thriftserver']` - Whether to enable the Spark Thrift Server.
