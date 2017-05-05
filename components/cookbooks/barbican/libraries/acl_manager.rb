require 'rest-client'

require '/usr/local/share/gems/gems/fog-openstack-0.1.19/lib/fog/openstack.rb'
require '/usr/local/share/gems/gems/fog-openstack-0.1.19/lib/fog/openstack/core.rb'

require 'fog/openstack'
require 'fog/core'
require 'fog/openstack/core'

#require '/Users/kpalan1/.rvm/gems/ruby-2.0.0-p647/gems/fog-openstack-0.1.20/lib/fog/openstack/core.rb'
#require '/Users/kpalan1/.rvm/gems/ruby-2.0.0-p647/gems/fog-openstack-0.1.20/lib/fog/openstack.rb'
require 'json'
require 'excon'

class ACLManager
  def initialize(endpoint, username, password, tenantname)
    fail ArgumentError, 'tenant is nil' if tenantname.nil?

    @connection_params = {
        openstack_auth_url:     "#{endpoint}",
        openstack_username:     "#{username}",
        openstack_api_key:      "#{password}",
        openstack_project_name: "#{tenantname}",
        #openstack_tenant:       "#{tenantname}",
        openstack_domain_id:    "default"

    }

  end

  def get_secret_acl(secret_uuid)

    key_manager = Fog::KeyManager::OpenStack.new(@connection_params)
    acl_obj = key_manager.get_secret_acl(secret_uuid)
    if !acl_obj.nil?
      return acl_obj
    end




  end

  def replace_secret_acl(secret_uuid, user_id_list)
    key_manager = Fog::KeyManager::OpenStack.new(@connection_params)
    user_uuid = Array.new

    data = {
        'read' => {
            'users'  => user_id_list,
            'project-access' => true
        }
    }

    response = key_manager.replace_secret_acl("17ca49d9-0804-4ba7-b931-d34cabaa1f04",
                                              data)
    return response.data


  end


  def delete_secret_acl(secret_ref)
    key_manager = Fog::KeyManager::OpenStack.new(@connection_params)
    response = key_manager.delete_secret_acl secret_ref.split("/").last
    return response.data
  end


  def get_container_acl(secret_ref)

    key_manager = Fog::KeyManager::OpenStack.new(@connection_params)
    acl_obj = key_manager.get_container_acl(secret_ref.split("/").last)
    if !acl_obj.nil?
      return acl_obj
    end




  end


  def replace_container_acl(secret_ref, user_id_list)
    key_manager = Fog::KeyManager::OpenStack.new(@connection_params)
    data = {
        'read' => {
            'users'  => user_id_list,
            'project-access' => true
        }
    }

    response = key_manager.replace_container_acl(secret_ref.split("/").last,
                                                 data)
    return response.data


  end


  def delete_container_acl(secret_ref)
    key_manager = Fog::KeyManager::OpenStack.new(@connection_params)
    response = key_manager.delete_container_acl secret_ref.split("/").last
    return response.data
  end
end