require File.expand_path('../../libraries/barbican_utils.rb', __FILE__)

secrets = get_secrets_wo()

container_name = node[:cert_container_name]
Chef::Log.info "Adding container #{container_name} ..."
  create_container(
   secrets[0][:secret_name],
   secrets[1][:secret_name],
   secrets[2][:secret_name],
   secrets[3][:secret_name],
   container_name,
   "certificate")

user_list = Array.new
user_list.push("octavia")

replace_acl(container_name,user_list,"container")

