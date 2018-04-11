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

attribute 'provider',
  :description => "Provider",
  :default => "Azure",
  :format => {
    :help => 'Please choose a provider',
    :category => '1.Config',
    :order => 1,
    :form => { 'field' => 'select', 'options_for_select' => [
        ['Azure','Azure'],
        ['Swift','Swift']
      ]
    }
  }


attribute 'storage_account_id',
    :description => 'Storage Account ID',
    :format => {
        :help => 'Storage Account Name',
        :category => '2.Authentication',
        :order => 1,
        :filter => {'all' => {'visible' => 'provider:eq:Azure', 'required' => 'provider:eq:Azure'}}
    }

attribute 'tenant_id',
          :description => 'Tenant ID',
          :default => 'Enter Tenant ID associated with Azure AD',
          :format => {
              :help => 'tenant id',
              :category => '2.Authentication',
              :order => 2,
              :filter => {'all' => {'visible' => 'provider:eq:Azure', 'required' => 'provider:eq:Azure'}}
            }

attribute 'client_id',
          :description => 'Client ID',
          :default => '',
          :format => {
              :help => 'client id',
              :category => '2.Authentication',
              :order => 3,
              :filter => {'all' => {'visible' => 'provider:eq:Azure', 'required' => 'provider:eq:Azure'}}
            }

attribute 'client_secret',
          :description => 'Client Secret',
          :encrypted => true,
          :default => '',
          :format => {
              :help => 'client secret azure',
              :category => '2.Authentication',
              :order => 4,
              :filter => {'all' => {'visible' => 'provider:eq:Azure', 'required' => 'provider:eq:Azure'}}
            }



attribute 'endpoint',
          :description => 'Auth Endpoint',
          :default => '',
          :format => {
            :help => 'Auth Endpoint URL',
            :category => '2.Authentication',
            :order => 1,
            :filter => {'all' => {'visible' => 'provider:eq:Swift', 'required' => 'provider:eq:Swift'}}
          }

attribute 'tenant',
          :description => 'Tenant',
          :default => '',
          :format => {
            :help => 'Tenant Name',
            :category => '2.Authentication',
            :order => 2,
            :filter => {'all' => {'visible' => 'provider:eq:Swift', 'required' => 'provider:eq:Swift'}}
          }

attribute 'regionname',
          :description => 'Region Name',
          :encrypted => false,
          :default => '',
          :format => {
            :help => 'Region Name Attribute',
            :category => '2.Authentication',
            :order => 3,
            :filter => {'all' => {'visible' => 'provider:eq:Swift', 'required' => 'provider:eq:Swift'}}
          }


attribute 'authstrategy',
          :description => 'Auth Strategy',
          :encrypted => false,
          :required => 'optional',
          :default => 'keystone',
          :format => {
            :help => 'Auth Strategy',
            :category => '2.Authentication',
            :order => 4,
            :filter => {'all' => {'visible' => 'provider:eq:Swift'}}
          }

attribute 'username',
          :description => 'Username',
          :format => {
            :help => 'Username',
            :category => '2.Authentication',
            :order => 5,
            :filter => {'all' => {'visible' => 'provider:eq:Swift', 'required' => 'provider:eq:Swift'}}
          }

attribute 'password',
          :description => 'Password',
          :encrypted => true,
          :format => {
            :help => 'Password',
            :category => '2.Authentication',
            :order => 6,
            :filter => {'all' => {'visible' => 'provider:eq:Swift', 'required' => 'provider:eq:Swift'}}
          }
