def whyrun_supported?
  true
end


action :create_container do
  secret_manager = SecretManager.new(@new_resource.openstack_auth_url, @new_resource.openstack_username, @new_resource.openstack_api_key, @new_resource.openstack_tenant)

  begin
    converge_by("Add secret certificate container through barbican API") do
      raise Exception.new("openstack_auth_url is required") if @new_resource.openstack_auth_url.nil?
      raise Exception.new("openstack_username is required") if @new_resource.openstack_username.nil?
      raise Exception.new("openstack_api_key  is required") if @new_resource.openstack_api_key.nil?
      raise Exception.new("tenant name is required") if @new_resource.openstack_tenant.nil?
      raise Exception.new("cert_ref  is required") if @new_resource.cert_name.nil?
      raise Exception.new("private_key_ref  is required") if @new_resource.private_key_name.nil?
      raise Exception.new("intermediates_ref  is required") if @new_resource.intermediates_name.nil?
      raise Exception.new("private_key_passphrase_ref is required") if @new_resource.private_key_passphrase_name.nil?
      raise Exception.new("container_name is required") if @new_resource.container_name.nil?
      raise Exception.new("type is required") if @new_resource.container_type.nil?

      secret_manager.create_container(@new_resource.container_name, @new_resource.container_type,
                                      @new_resource.cert_name, @new_resource.private_key_name,
                                      @new_resource.intermediates_name, @new_resource.private_key_passphrase_name)
    end
    @new_resource.updated_by_last_action(true)
  rescue => ex
    Chef::Log.error(ex.inspect)
    actual_err = "An error of type #{ex.class} happened, message is #{ex.message}"
    msg = "Exception creating new certificate container through Barbican API , " + actual_err
    puts "***FAULT:FATAL=#{msg}"
    e = Exception.new(msg)
    raise e
  end

  end

action :delete_container do
  begin
    converge_by("Delete secret certificate container through barbican API") do
      raise Exception.new("openstack_auth_url is required") if @new_resource.openstack_auth_url.nil?
      raise Exception.new("openstack_username is required") if @new_resource.openstack_username.nil?
      raise Exception.new("openstack_api_key  is required") if @new_resource.openstack_api_key.nil?
      raise Exception.new("tenant name is required") if @new_resource.openstack_tenant.nil?
      raise Exception.new("container_name  is required") if @new_resource.container_name.nil?


      secret_manager = SecretManager.new(@new_resource.openstack_auth_url, @new_resource.openstack_username, @new_resource.openstack_api_key, @new_resource.openstack_tenant )
      container_ref = secret_manager.get_container(@new_resource.container_name)
      if container_ref != false && !container_ref.nil?
          Chef::Log.info("container_ref for #{@new_resource.container_name}:#{container_ref}")
          node.set['delete_container_result']=secret_manager.delete_container(container_ref.split('/').last)
      else
        Chef::Log.warn("container_ref for #{@new_resource.container_name} is empty")
      end
    end
    @new_resource.updated_by_last_action(true)

  rescue => ex
    Chef::Log.error(ex.inspect)
    actual_err = "An error of type #{ex.class} happened, message is #{ex.message}"
    msg = "Exception deleting certificate container through Barbican API , " + actual_err
    puts "***FAULT:FATAL=#{msg}"
    e = Exception.new(msg)
    raise e
  end

end