include_recipe "keywhiz-client::set_attributes"

cloud_name = node[:workorder][:cloud][:ciName]
provider = ""
cert_service = node[:workorder][:services][:certificate]

if ! cert_service.nil? && ! cert_service[cloud_name].nil?
        provider = node[:workorder][:services][:certificate][cloud_name][:ciClassName].gsub("cloud.service.","").downcase.split(".").last
else
        Chef::Log.error("Certificate cloud service not defined for this cloud")
        exit 1
end

ci_id = node.workorder.rfcCi.ciId

certificate = Hash.new
certificate["common_name"] = "keywhiz-" + ci_id.to_s
certificate["owner_email"] = node.keywhiz_sync_cert_owner_dl

node.set[:certificate] = certificate
Chef::Log.info("common is: " + certificate["common_name"])
include_recipe provider + "::delete_cert"


