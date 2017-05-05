actions :create_container, :update_contianer, :delete_container
default_action :add_container

attribute :openstack_auth_url, :kind_of => String, :required => true
attribute :openstack_username, :kind_of => String, :required => true
attribute :openstack_api_key, :kind_of => String, :required => true
attribute :openstack_project_name, :kind_of => String, :required => true
attribute :openstack_tenant, :kind_of => String, :required => true
attribute :secret_name, :kind_of => String, :required => true
attribute :secret_content, :kind_of => String, :required => true
attribute :secretcontainer, :kind_of => Hash, :required => true
attribute :secret_ref, :kind_of => String, :required => true
attribute :payload_content_type, :kind_of => String, :required => true
attribute :algorithm, :kind_of => String, :required => true
attribute :bit_length, :kind_of => Integer, :required => true
attribute :mode, :kind_of => String, :required => true
attribute :cert_name, :kind_of => String, :required => false
attribute :private_key_name, :kind_of => String, :required => false
attribute :intermediates_name, :kind_of => String, :required => false
attribute :private_key_passphrase_name, :kind_of => String, :required => false
attribute :container_name, :kind_of => String, :required => false
attribute :container_type, :kind_of => String, :required => false
