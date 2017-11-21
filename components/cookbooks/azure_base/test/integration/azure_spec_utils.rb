class AzureSpecUtils
  def initialize(node)
    @node = node
  end

  def get_app_type
    @node['app_name']
  end
  def get_cloud_name
    cloud_name = @node['workorder']['cloud']['ciName']
    cloud_name
  end
  def get_rfc_ci
    rfcCi = @node['workorder']['rfcCi']
    rfcCi
  end
  def get_ns_path_parts
    rfcCi = get_rfc_ci
    nsPathParts = rfcCi['nsPath'].split("/")
    nsPathParts
  end
  def get_service
    cloud_name = get_cloud_name
    app_type = get_app_type
    svc = case app_type
            when 'lb'
              @node['workorder']['services']['lb'][cloud_name]['ciAttributes']
            when 'fqdn'
              @node['workorder']['services']['dns'][cloud_name]['ciAttributes']
            when 'storage'
              @node['workorder']['services']['storage'][cloud_name]['ciAttributes']
            else
              @node['workorder']['services']['compute'][cloud_name]['ciAttributes']
          end
  end
  def get_resource_group_name
    nsPathParts = get_ns_path_parts
    org = nsPathParts[1]
    assembly = nsPathParts[2]
    environment = nsPathParts[3]

    svc = get_service
    location = svc['location']

    resource_group_name = org[0..15] + '-' + assembly[0..15] + '-' + @node['workorder']['box']['ciId'].to_s + '-' + environment[0..15] + '-' + Utils.abbreviate_location(location)
    resource_group_name
  end

  def get_location


      app_type = get_app_type
      svc = get_service

      location = case app_type
                   when 'lb', 'fqdn'
                     svc['location']
                   when 'storage'
                     svc['region']
                   else
                     svc['location']
                 end
      location

  end

  def get_azure_creds
    cloud_name = get_cloud_name
    app_type = get_app_type
    svc = get_service

    credentials = {
        tenant_id: svc['tenant_id'],
        client_secret: svc['client_secret'],
        client_id: svc['client_id'],
        subscription_id: svc['subscription']
    }

    credentials
  end
  def get_image_id
    #image_id is a calculated attributed. This is calculated in Compute::node_lookup recipe
    os = nil
    ostype = "default-cloud"

    cloud_name = get_cloud_name
    cloud = @node['workorder']['services']['compute'][cloud_name]['ciAttributes']
    rfcCi = get_rfc_ci

    if @node['workorder']['payLoad'].has_key?("os")
      os = @node['workorder']['payLoad']['os'].first
      ostype = os['ciAttributes']['ostype']
    else
      if ostype == "default-cloud"
        ostype = cloud['ostype']
      end
    end

    sizemap = JSON.parse( cloud['sizemap'] )
    imagemap = JSON.parse( cloud['imagemap'] )
    size_id = sizemap[rfcCi["ciAttributes"]["size"]]

    image_id = ''
    if !os.nil? && os['ciAttributes'].has_key?("image_id") && !os['ciAttributes']['image_id'].empty?
      image_id = os['ciAttributes']['image_id']
    else
      image_id = imagemap[ostype]
    end

    image_id
  end
  def set_attributes_on_node_required_for_vm_manager
    @node.set['image_id'] = get_image_id
    @node.set['platform-resource-group'] = get_resource_group_name
  end
  def is_express_route_enabled
    set_attributes_on_node_required_for_vm_manager
    vm_manager = AzureCompute::VirtualMachineManager.new(@node)
    express_route_enabled = vm_manager.compute_service['express_route_enabled']

    if(express_route_enabled == "true")
      return true
    else
      false
    end
  end

  def get_server_name
    rfcCi = get_rfc_ci
    nsPathParts = get_ns_path_parts


    server_name = @node['workorder']['box']['ciName']+'-'+nsPathParts[3]+'-'+nsPathParts[2]+'-'+nsPathParts[1]+'-'+ rfcCi["ciId"].to_s
    if(server_name.size > 63)
      server_name = server_name.slice(0,63-(rfcCi["ciId"].to_s.size)-1)+'-'+ rfcCi["ciId"].to_s
    end

    server_name
  end
  def get_lb_name
    platform_name = @node['workorder']['box']['ciName']
    plat_name = platform_name.gsub(/-/, '').downcase
    lb_name = "lb-#{plat_name}"

    lb_name
  end

  # Converts the hash given by the node according to the new syntax
  def get_dns_attributes
    cloud_name = get_cloud_name
    dns_attributes = @node['workorder']['services']['dns'][cloud_name]['ciAttributes']

    dns_attributes_hash = get_azure_creds
    dns_attributes_hash[:subscription] = dns_attributes_hash[:subscription_id]
    dns_attributes_hash[:zone] = dns_attributes['zone']
    dns_attributes_hash[:cloud_dns_id] = dns_attributes['cloud_dns_id']

    dns_attributes_hash.delete :subscription_id
    dns_attributes_hash
  end

  # Returns name of a DNS record
  def get_record_set_name
    ns_path_parts = get_ns_path_parts
    org = ns_path_parts[1]
    assembly = ns_path_parts[2]
    environment = ns_path_parts[3]
    ci_name = @node['workorder']['box']['ciName']

    dns_attributes = get_dns_attributes

    record_set_name = "#{ci_name}.#{environment}.#{assembly}.#{org}.#{dns_attributes[:cloud_dns_id]}"
    record_set_name.downcase!
    record_set_name
  end

  # Gets public IPs of all VMs deployed
  def get_all_vms_public_ips
    ip_addresses = []
    @node['workorder']['payLoad']['RequiresComputes'].each do |vm_data|
      ip_addresses << vm_data['ciAttributes']['public_ip']
    end

    ip_addresses
  end

  # Get public IP of the LB deployed
  def get_lb_public_ip
    lb_ip_address = []
    @node['workorder']['payLoad']['lb'].each do |lb_data|
      lb_ip_address << lb_data['ciAttributes']['dns_record']
    end

    lb_ip_address
  end

  # checks the existence of load balancer in the deployment
  def lb_exists?
    $node['workorder']['payLoad'].key?('lb')
  end
end
