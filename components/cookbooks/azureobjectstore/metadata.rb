name             'Azureobjectstore'
maintainer       '@WalmartLabs'
maintainer_email 'umullangi@walmartlabs.com'
license          'All rights reserved'
description      'Installs/Configures azure objectstore service'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
grouping 'default',
         :access => 'global',
         :packages => %w[base service.filestore mgmt.cloud.service cloud.service cloud.zone.service],
         :namespace => true

attribute 'storage_account_id',
          :description => 'Storage Account ID',
          :required => 'required',
          :format => {
            :help => 'Storage Account Name',
            :category => '1.Authentication',
            :order => 1
          }

attribute 'tenant_id',
          :description => 'Tenant ID',
          :required => 'required',
          :default => 'Enter Tenant ID associated with Azure AD',
          :format => {
              :help => 'tenant id',
              :category => '1.Authentication',
              :order => 2
}

attribute 'client_id',
          :description => 'Client ID',
          :required => 'required',
          :default => '',
          :format => {
              :help => 'client id',
              :category => '1.Authentication',
              :order => 3
          }

attribute 'client_secret',
          :description => 'Client Secret',
          :encrypted => true,
          :required => 'required',
          :default => '',
          :format => {
              :help => 'client secret azure',
              :category => '1.Authentication',
              :order => 4
          }
