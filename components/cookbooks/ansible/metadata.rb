name             'Ansible'
maintainer       'OneOps'
maintainer_email 'support@oneops.com'
license          'Apache License, Version 2.0'
license          'Apache 2.0'
description      'Installs/Configures ansible'
version          '0.1.0'

grouping 'bom',
         :access => 'global',
         :packages => ['bom']

grouping 'default',
         :access => 'global',
         :packages => ['base', 'mgmt.catalog', 'mgmt.manifest', 'catalog', 'manifest', 'bom']

attribute 'ansible_version',
          :description => 'Version',
          :required    => 'required',
          :default     => '2.2.0.0',
          :format      => {
            :help     => 'Ansible version to install',
            :category => '1.Ansible',
            :order    => 1
          }

attribute 'roles',
          :description => 'roles',
          :required    => 'required',
          :data_type => "text",
          :default     => "changeme",
          :format      => {
            :help     => 'Pip Config',
            :category => '1.Ansible',
            :order    => 2
          }

attribute 'playbook',
          :description => 'playbook',
          :required    => 'required',
          :data_type => "text",
          :default     => "changeme",
          :format      => {
            :help     => 'Playbook',
            :category => '2.Pip',
            :order    => 2
          }

attribute 'pip_proxy_content',
          :description => 'Pip Proxy Content',
          :data_type => "text",
          :default     => "$OO_CLOUD{PIP_PROXY_CONFIG}",
          :format      => {
            :help     => 'Pip ',
            :category => '2.Pip',
            :order    => 1
          }
          