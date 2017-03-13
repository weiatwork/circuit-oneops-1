name             "Rabbitmq-cluster"
description      "Setup/Configure Rabbitmq Cluster"
version          "0.1"
maintainer       "OneOps"
maintainer_email "support@oneops.com"
license          "Copyright OneOps, All rights reserved."

grouping 'default',
  :access => "global",
  :packages => [ 'base', 'mgmt.catalog', 'mgmt.manifest', 'catalog', 'manifest', 'bom' ]

recipe "start", "start app"
recipe "stop", "stop app"
recipe "join", "join cluster"
