require File.expand_path('../../libraries/barbican_utils.rb', __FILE__)

# get the necessary information from the node
service = BarbicanUtils.get_service_info(node)

secrets = BarbicanUtils.get_secrets(node)
secrets_name_list = Array.new
Chef::Log.info("url:#{service[:openstack_auth_url]}")

secrets.each do |secret|
  Chef::Log.info "Adding #{secret[:secret_name]} ..."

  secret_config = barbican_secret 'Add Barbican Secret' do
    openstack_auth_url service[:openstack_auth_url]
    openstack_username service[:openstack_username]
    openstack_api_key service[:openstack_api_key]
    openstack_project_name service[:openstack_project_name]
    openstack_tenant service[:openstack_tenant]
    Chef::Log.info("#{secret[:secret_name]}")
    secret_name secret[:secret_name]
    secret_content secret[:content]
    payload_content_type "text/plain"
    algorithm "aes"
    bit_length 256
    mode "cbc"
    action :nothing
    #action :add_secret do
     # Chef::Log.info("Pushing #{node['secret_ref']} ...")
    # end
  end

  secret_config.run_action(:add_secret)
end
