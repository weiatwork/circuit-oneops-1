require File.expand_path('../../libraries/barbican_utils.rb', __FILE__)

service = BarbicanUtils.get_service_info(node)

secrets = BarbicanUtils.get_secrets(node)

container_name = node[:cert_container_name]
Chef::Log.info "Adding container #{container_name} ..."
barbican_container 'Add barbican container' do

  openstack_auth_url service[:openstack_auth_url]
  openstack_username service[:openstack_username]
  openstack_api_key service[:openstack_api_key]
  openstack_project_name service[:openstack_project_name]
  openstack_tenant service[:openstack_tenant]
  cert_name secrets[0][:secret_name]
  intermediates_name secrets[1][:secret_name]
  private_key_name secrets[2][:secret_name]
  private_key_passphrase_name secrets[3][:secret_name]
  container_name container_name
  container_type "certificate"
  action :create_container

end

