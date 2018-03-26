name             "Medusa-kafka-broker"
description      "Cloud service for Kafka Broker where Medusa telegraf metrics will be sent to"
version          "1.0"
maintainer       "OneOps"
maintainer_email "support@oneops.com"
license          "Apache License, Version 2.0"
depends          "shared"

grouping 'default',
  :access => "global",
  :packages => [ 'base', 'mgmt.catalog', 'mgmt.manifest', 'catalog', 'manifest', 'bom' ]

grouping 'service',
  :access => "global",
  :packages => [ 'mgmt.cloud.service', 'cloud.service'  ],
  :namespace => true

attribute 'url',
  :grouping => 'service',
  :description => "Kafka Broker URL",
  :required => "required",
  :default => '',
  :format => { 
    :help => 'Kafka Broker URL (for e.g: kafka.kafka-cluster-telemetry.prod1-ndc.walmart.com:9092)',
    :category => '1.Repository',
    :order => 1
  }
