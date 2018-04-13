name             'Objectstore'
maintainer       '@walmartlabs'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures object-store'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
grouping 'default',
         :access => "global",
         :packages => ['base', 'mgmt.catalog', 'mgmt.manifest', 'catalog', 'manifest', 'bom']

attribute 'storage',
  :description => 'Storage',
  :required => 'required',
  :format => {
      :help => 'Region Name for Openstack and Storage Account ID for Azure',
      :category => '1.Authentication',
      :order => 1
  }
