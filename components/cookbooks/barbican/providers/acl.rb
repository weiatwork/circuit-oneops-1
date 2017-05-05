def whyrun_supported?
  true
end


action :replace_acl do
  acl_manager = ACLManager.new(@new_resource.openstack_auth_url, @new_resource.openstack_username, @new_resource.openstack_api_key, @new_resource.openstack_tenant)
  if @new_resource.type == "secret"
  acl_manager.replace_secret_acl(@new_resource.secret_id, @new_resource.uuidlist)
end
