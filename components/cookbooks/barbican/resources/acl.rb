actions :add_secret, :update_secret, :delete_secret, :add_container, :update_contianer, :delete_container
default_action :add

attribute :openstack_auth_url, :kind_of => String, :required => true
attribute :openstack_username, :kind_of => String, :required => true
attribute :openstack_api_key, :kind_of => String, :required => true
attribute :openstack_project_name, :kind_of => String, :required => true
attribute :openstack_tenant, :kind_of => String, :required => true
attribute :secret_name, :kind_of => String, :required => true
attribute :uuidlist, :kind_of => Array, :required => true
attribute :operation_type, :kind_of => String, :required => true
attribute :project_access, :kind_of => String, :required => true
attribute :type, :kind_of => String, :required => true

