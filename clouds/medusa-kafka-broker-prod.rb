name "medusa-kafka-broker-prod"
description "Cloud service for Kafka Broker where Medusa telegraf metrics will be sent to"
  
service "medusa-kafka-broker-service",
  :cookbook => 'Medusa-Kafka-Broker',
  :source => [Chef::Config[:register], Chef::Config[:version].split(".").first].join('.'),  
  :provides => { :service => 'monitoring' },
  :attributes => {
    :url => '',
  }
