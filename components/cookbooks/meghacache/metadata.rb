name             'Meghacache'
description      'MeghaCache'
version          "0.1"
maintainer       "OneOps"
maintainer_email "support@oneops.com"
license          "Apache License, Version 2.0"

grouping 'default',
  :access => "global",
  :packages => [ 'base', 'mgmt.catalog', 'mgmt.manifest', 'catalog', 'manifest' ]

grouping 'bom',
  :access => "global",
  :packages => [ 'bom' ]

attribute 'graphite_logfiles_path',
            :description => 'Graphite Metrics Tool Logfiles Path',
            :required => 'required',
            :default => '/opt/meghacache/log/graphite/graphite_stats.log',
            :format => {
                :help => 'Directory for graphite metrics tool logs',
                :category => '1.Global',
                :order => 1,
                :editable => false
            }
