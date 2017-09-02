include_pack 'base'

name 'mssql'
description 'MS SQL Server'
type 'Platform'
category 'Database Relational SQL'
ignore false
version '0.2'

platform :attributes => {'autoreplace' => 'false', 'autocomply' => 'true'}

environment 'single', {}

variable 'temp-drive',
  :description => 'Temp Drive',
  :value       => 'T'

variable 'data-drive',
  :description => 'Data Drive',
  :value       => 'F'

variable 'tcp-port',
  :description => 'TCP Port',
  :value       => '1433'

variable 'mirroring-port',
  :description => 'Mirroring Endpoint Port',
  :value       => '5022'

variable 'ag-name',
  :description => 'Availability Group Name',
  :value       => 'AG1'

resource 'secgroup',
         :cookbook => 'oneops.1.secgroup',
         :design => true,
         :attributes => {
             'inbound' => '[ "22 22 tcp 0.0.0.0/0", "$OO_LOCAL{tcp-port} $OO_LOCAL{tcp-port} tcp 0.0.0.0/0", "3389 3389 tcp 0.0.0.0/0", "$OO_LOCAL{mirroring-port} $OO_LOCAL{mirroring-port} tcp 0.0.0.0/0"]'
         },
         :requires => {
             :constraint => '1..1',
             :services => 'compute'
         }


resource 'mssql',
  :cookbook => 'oneops.1.mssql',
  :design   => true,
  :requires => {
    :constraint => '1..1',
    :services   => 'mirror'
  },
  :attributes   => {
    'version' => 'mssql_2014_enterprise',
    'tcp_port' => '$OO_LOCAL{tcp-port}',
    'tempdb_data' => '$OO_LOCAL{temp-drive}:\\MSSQL',
    'tempdb_log' => '$OO_LOCAL{temp-drive}:\\MSSQL',
    'userdb_data' => '$OO_LOCAL{data-drive}:\\MSSQL\\UserData',
    'userdb_log' => '$OO_LOCAL{data-drive}:\\MSSQL\\UserLog',
    'mirroring_port' => '$OO_LOCAL{mirroring-port}',
    'password_sa' => ''
  },
  :monitors => {
  'mssql' =>  { :description => 'MSSQL Service check',
     :chart => {'min'=>0},
     :cmd => 'sql_servicemonitor.ps1',
     :cmd_line => 'powershell.exe -file /opt/nagios/libexec/sql_servicemonitor.ps1',
     :metrics =>  {
       'mssqlup'  => metric( :unit => 'mssqlup', :description => 'MSSQL Status'),
       'agentup'  => metric( :unit => 'agentup', :description => 'SQLAGENT status')
     },
     :thresholds => {
        'MssqlProcessDown' => threshold('1m', 'avg', 'mssqlup', trigger('<=', 98, 1, 1), reset('>', 95, 1, 1),'unhealthy'),
        'AgentProcessDown' => threshold('1m', 'avg', 'agentup', trigger('<=', 98, 1, 1), reset('>', 95, 1, 1),'unhealthy')
     },
   },
    'databasecheck' =>  { :description => 'MSSQL DB status check',
       :chart => {'min'=>0},
       :cmd => 'sql_dbcount.ps1',
       :cmd_line => 'powershell.exe -file /opt/nagios/libexec/sql_dbcount.ps1',
       :metrics =>  {
         'totaldbs'  => metric(:unit => 'totaldbs', :description => 'Total Number of databases'),
         'offlinedbs'  => metric(:unit => 'offlinedbs', :description => 'Total Number of offline databases'),
       },
       :thresholds  => {
        'offlinedbs' => threshold('1m', 'avg', 'offlinedbs', trigger('>=', 1, 1, 1), reset('<', 1, 1, 1)),
       }
     },
      'latencies' =>  { :description => 'Disk latencies',
         :chart => {'min'=>0},
         :cmd => 'sql_disklatency.ps1',
         :cmd_line => 'powershell.exe -file /opt/nagios/libexec/sql_disklatency.ps1',
         :metrics =>  {
           'logical'  => metric(:unit => 'logical', :description => 'Logical disk latency'),
           'physical'  => metric(:unit => 'physical', :description => 'Physical disk latency'),
         },
         :thresholds  => {
          'logical' => threshold('1m', 'avg', 'logical', trigger('>', 0.015, 1, 1), reset('<', 0.015, 1, 1)),
          'physical' => threshold('1m', 'avg', 'physical', trigger('>', 0.015, 1, 1), reset('<', 0.015, 1, 1))
         }
       }
  }

resource 'compute',
  :cookbook => 'oneops.1.compute',
  :attributes => { 'size'    => 'M-WIN' }

resource 'storage',
  :cookbook => 'oneops.1.storage',
  :requires => { 'constraint' => '1..*', 'services' => 'storage' }

resource 'volume',
  :cookbook => 'oneops.1.volume',
  :requires => {'constraint' => '1..*', 'services' => 'compute,storage'},
  :attributes => { 'mount_point'    => '$OO_LOCAL{data-drive}' }

resource 'vol-temp',
  :cookbook => 'oneops.1.volume',
  :requires => { 'constraint' => '1..1', 'services' => 'compute' },
  :attributes => { 'mount_point'    => '$OO_LOCAL{temp-drive}' }

resource 'os',
  :cookbook => 'oneops.1.os',
  :design => true,
  :requires => {
    :constraint => '1..1',
    :services   => 'compute,*mirror,*ntp,*windows-domain'
    },
    :attributes => {
    :ostype => 'windows_2012_r2',
    :features => '["Failover-Clustering -IncludeManagementTools","RSAT-AD-Powershell"]'
  }

resource 'dotnetframework',
  :cookbook     => 'oneops.1.dotnetframework',
  :design       => true,
  :requires     => {
    :constraint => '1..1',
    :help       => 'Installs .net frameworks',
    :services   => 'compute,*mirror'
  },
  :attributes   => {
    :chocolatey_package_source   => 'https://chocolatey.org/api/v2/',
    :dotnet_version_package_name => '{ ".Net 4.6":"dotnet4.6", ".Net 3.5":"dotnet3.5" }'
  }

resource 'database',
  :cookbook      => "oneops.1.database",
  :design        => true,
  :requires      => {
    :constraint  => '0..*',
    :help        => 'Installs user database'
  }

resource 'custom-config',
  :cookbook      => "oneops.1.artifact",
  :design        => true,
  :requires      => {
    :constraint  => '0..*',
    :help        => 'Installs custom configuration scripts'
  },
  :attributes       => {
     :install_dir   => '$OO_LOCAL{temp-drive}:/mssql-config',
     :as_user       => 'oneops',
     :as_group      => 'Administrators'
}

resource 'cluster',
  :only => [ 'redundant' ],
  :design => false,
  :cookbook => 'oneops.1.cluster',
  :requires => { :constraint => '1..1' ,
                 :services   => 'compute,windows-domain'},
  :payloads => {
   'hostnames' => {
     'description' => 'Hostnames',
     'definition' => '{
       "returnObject": false,
       "returnRelation": false,
       "relationName": "base.RealizedAs",
       "direction": "to",
       "targetClassName": "manifest.oneops.1.Cluster",
       "relations": [
         { "returnObject": false,
           "returnRelation": false,
           "relationName": "manifest.ManagedVia",
           "direction": "from",
           "targetClassName": "manifest.oneops.1.Compute",
           "relations": [
             { "returnObject": false,
               "returnRelation": false,
               "relationName": "base.RealizedAs",
               "direction": "from",
               "targetClassName": "bom.oneops.1.Compute",
               "relations": [
                 { "returnObject": true,
                   "returnRelation": false,
                   "relationName": "bom.DependsOn",
                   "direction": "to",
                   "targetClassName": "bom.oneops.1.Fqdn"
                 }
                ]
             }
            ]
         }
        ]
     }'
   }
  }

resource 'lb',
  :only => [ 'redundant' ],
  :design => true,
  :cookbook => 'oneops.1.lb',
  :requires => { :constraint => '1..1',
                 :services   => 'compute,lb,dns' ,
                 :help       => 'Internal Load Balancer for AlwaysOn Listener'},
  :attributes => {
                   :stickiness => '',
                   :listeners  => '[ "mssql $OO_LOCAL{tcp-port} mssql $OO_LOCAL{tcp-port}"]',
                   :ecv_map    =>  '{ "$OO_LOCAL{tcp-port}|userName" : "oneops",
                                      "$OO_LOCAL{tcp-port}|sqlQuery" : "select 1 from sys.availability_groups ag join sys.dm_hadr_availability_replica_states rs on rs.group_id = ag.group_id and rs.role = 1 and rs.operational_state = 2 join sys.availability_replicas r on r.replica_id = rs.replica_id where ag.name = \'$OO_LOCAL{ag-name}\'  and r.replica_server_name = @@SERVERNAME",
                                      "$OO_LOCAL{tcp-port}|evalRule" : "MSSQL.RES.TYPE.NE(ERROR).AND(MSSQL.RES.ATLEAST_ROWS_COUNT(1))",
                                      "$OO_LOCAL{tcp-port}|storedb"  : "EN"}'
                   }

#Disable fqdn resource, and replace with fqdn-cluster
resource 'fqdn',
  :cookbook => 'oneops.1.fqdn',
  :only => [ '_default', 'redundant' ],
  :design => true,
  :requires => { :constraint => '1..1' ,
                 :services   => 'dns,windows-domain,*gdns',
                 :help       => 'DNS entry for listener'}

resource 'hostname',
  :cookbook => 'oneops.1.fqdn',
  :design => true,
  :requires => { :constraint => '1..1' ,
                 :services   => 'dns,windows-domain,*gdns',
                 :help       => 'DNS entry for hostname'}

resource 'fqdn-cluster',
  :cookbook => 'oneops.1.fqdn',
  :only => [ 'redundant' ],
  :design => false,
  :requires => { :constraint => '1..1' ,
                 :services   => 'dns,windows-domain,*gdns',
                 :help       => 'DNS entry for cluster name'},
  :payloads => {
    'os_payload' => {
     'description' => 'Os payload',
     'definition' => '{
       "returnObject": false,
       "returnRelation": false,
       "relationName": "base.RealizedAs",
       "direction": "to",
       "targetClassName": "manifest.oneops.1.Fqdn",
       "relations": [
         { "returnObject": false,
           "returnRelation": false,
           "relationName": "manifest.Requires",
           "direction": "to",
           "targetClassName": "manifest.Platform",
           "relations": [
             { "returnObject": true,
               "returnRelation": false,
               "relationName": "manifest.Requires",
               "direction": "from",
               "targetClassName": "manifest.oneops.1.Os"
             }
            ]
         }
       ]
     }'
   }
  }

resource 'availability-group',
  :cookbook => 'oneops.1.mssql_ag',
  :only => [ '_default', 'redundant' ],
  :design => true,
  :requires => { :constraint => '1..1',
                 :services => 'windows-domain' },
  :attributes   => {:ag_name => '$OO_LOCAL{ag-name}' },
  :payloads => {
    'ag_lb' => {
     'description' => 'LB component for Msql_ag resource',
     'definition' => '{
       "returnObject": false,
       "returnRelation": false,
       "relationName": "base.RealizedAs",
       "direction": "to",
       "targetClassName": "manifest.oneops.1.Mssql_ag",
       "relations": [
         { "returnObject": false,
           "returnRelation": false,
           "relationName": "manifest.Requires",
           "direction": "to",
           "targetClassName": "manifest.Platform",
           "relations": [
             { "returnObject": false,
               "returnRelation": false,
               "relationName": "manifest.Requires",
               "direction": "from",
               "targetClassName": "manifest.oneops.1.Lb",
               "relations": [
                 { "returnObject": true,
                   "returnRelation": false,
                   "relationName": "base.RealizedAs",
                   "direction": "from",
                   "targetClassName": "bom.oneops.1.Lb"
                 }
                ]
             }
            ]
         }
       ]
     }'
   },
     'ag_cluster' => {
     'description' => 'Cluster component for Msql_ag resource',
     'definition' => '{
       "returnObject": false,
       "returnRelation": false,
       "relationName": "base.RealizedAs",
       "direction": "to",
       "targetClassName": "manifest.oneops.1.Mssql_ag",
       "relations": [
         { "returnObject": false,
           "returnRelation": false,
           "relationName": "manifest.Requires",
           "direction": "to",
           "targetClassName": "manifest.Platform",
           "relations": [
             { "returnObject": false,
               "returnRelation": false,
               "relationName": "manifest.Requires",
               "direction": "from",
               "targetClassName": "manifest.oneops.1.Cluster",
               "relations": [
                 { "returnObject": true,
                   "returnRelation": false,
                   "relationName": "base.RealizedAs",
                   "direction": "from",
                   "targetClassName": "bom.oneops.1.Cluster"
                 }
                ]
             }
            ]
         }
       ]
     }'
   },
     'ag_os' => {
     'description' => 'Os components for Msql_ag resource',
     'definition' => '{
       "returnObject": false,
       "returnRelation": false,
       "relationName": "base.RealizedAs",
       "direction": "to",
       "targetClassName": "manifest.oneops.1.Mssql_ag",
       "relations": [
         { "returnObject": false,
           "returnRelation": false,
           "relationName": "manifest.Requires",
           "direction": "to",
           "targetClassName": "manifest.Platform",
           "relations": [
             { "returnObject": false,
               "returnRelation": false,
               "relationName": "manifest.Requires",
               "direction": "from",
               "targetClassName": "manifest.oneops.1.Os",
               "relations": [
                 { "returnObject": true,
                   "returnRelation": false,
                   "relationName": "base.RealizedAs",
                   "direction": "from",
                   "targetClassName": "bom.oneops.1.Os"
                 }
                ]
             }
            ]
         }
       ]
     }'
   }
  }

#disable volume-user relation from base.rb
relation 'volume::depends_on::user',
  :except => [ '_default', 'single' , 'redundant'],
  :relation_name => 'DependsOn',
  :from_resource => 'volume',
  :to_resource   => 'user',
  :attributes    => { "flex" => false, "min" => 1, "max" => 1 }

#DependsOn relations
[ 
  { :from => 'storage', :to => 'os' },
  { :from => 'vol-temp', :to => 'os' },
  { :from => 'dotnetframework', :to => 'vol-temp' },
  { :from => 'mssql', :to => 'volume' } ,
  { :from => 'mssql', :to => 'dotnetframework' } ,
  { :from => 'database', :to => 'mssql' } ,
  { :from => 'custom-config', :to => 'mssql' }
].each do |link|
  relation "#{link[:from]}::depends_on::#{link[:to]}",
    :relation_name => 'DependsOn',
    :from_resource => link[:from],
    :to_resource   => link[:to],
    :attributes    => { 'flex' => false, 'min' => 1, 'max' => 1 }
end


[ 'lb' ].each do |from|
  relation "#{from}::depends_on::compute",
    :only => [ 'redundant' ],
    :relation_name => 'DependsOn',
    :from_resource => from,
    :to_resource   => 'compute',
    :attributes    => { "propagate_to" => 'to', "flex" => true, "current" =>2, "min" => 2, "max" => 10}
end


# -d name due to pack sync logic uses a map keyed by that name - it doesnt get put into cms
[ 'lb' ].each do |from|
  relation "#{from}::depends_on::compute-d",
    :only => [ '_default' ],
    :relation_name => 'DependsOn',
    :from_resource => from,
    :to_resource   => 'compute',
    :attributes    => { "flex" => false }
end


[ 'fqdn' ].each do |from|
  relation "#{from}::depends_on::lb",
    :except => [ 'single' ],
    :relation_name => 'DependsOn',
    :from_resource => from,
    :to_resource   => 'lb',
    :attributes    => { "propagate_to" => 'both', "flex" => false, "min" => 1, "max" => 1 }
end

relation 'cluster::depends_on::fqdn',
  :only => [ 'redundant' ],
  :relation_name => 'DependsOn',
  :from_resource => 'cluster',
  :to_resource   => 'fqdn',
  :attributes    => { 'flex' => false, 'min' => 1, 'max' => 1 }

[ 'fqdn-cluster' ].each do |from|
  relation "#{from}::depends_on::cluster",
    :only => [ 'redundant' ],
    :relation_name => 'DependsOn',
    :from_resource => from,
    :to_resource   => 'cluster',
    :attributes    => { 'propagate_to' => 'from', "flex" => false, "min" => 1, "max" => 1 }
end

#AG relations for _default mode
[ { :from => 'availability-group', :to => 'mssql'}].each do |link|
  relation "#{link[:from]}::depends_on::#{link[:to]}",
    :only => [ '_default', 'redundant' ],
    :relation_name => 'DependsOn',
    :from_resource => link[:from],
    :to_resource   => link[:to],
    :attributes    => { 'flex' => false, 'min' => 1, 'max' => 1 }
end

[ { :from => 'availability-group', :to => 'custom-config'}].each do |link|
  relation "#{link[:from]}::depends_on::#{link[:to]}-d",
    :only => [ '_default', 'redundant' ],
    :relation_name => 'DependsOn',
    :from_resource => link[:from],
    :to_resource   => link[:to],
    :attributes    => { 'flex' => false, 'min' => 1, 'max' => 1 }
end


# ManagedVia
[ 'cluster','availability-group'].each do |from|
#[ 'cluster'].each do |from|
  relation "#{from}::managed_via::compute",
    :except => [ '_default', 'single' ],
    :relation_name => 'ManagedVia',
    :from_resource => from,
    :to_resource   => 'compute',
    :attributes    => { }
end

[ 'mssql', 'dotnetframework', 'os', 'volume', 'vol-temp', 'custom-config', 'database' ].each do |from|
  relation "#{from}::managed_via::compute",
    :except => [ '_default' ],
    :relation_name => 'ManagedVia',
    :from_resource => from,
    :to_resource   => 'compute',
    :attributes    => { }
end
