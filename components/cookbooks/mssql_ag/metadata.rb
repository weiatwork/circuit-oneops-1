name             'Mssql_ag'
description      'Configures AlwaysOn Availability Groups for MS SQL Server'
version          '0.1.0'
maintainer       'OneOps'
maintainer_email 'support@oneops.com'
license          'Apache License, Version 2.0'

depends 'windows-utils'

grouping 'default',
  :access   => 'global',
  :packages => [ 'base', 'mgmt.catalog', 'mgmt.manifest', 'catalog', 'manifest', 'bom' ]

attribute 'ag_name',
  :description => 'Availability Group Name',
  :required => 'required',
  :format => {
    :help => 'Specify Always-On Availability Group name',
    :category => '1.General',
    :order => 1
  }
