#
# Cookbook Name :: solrcloud
# Library :: CloudProvider

require 'json'

# This class is used to implement cloud provider specific code. 
class CloudProvider
  
  def initialize(node)
    #get the current node's cloud name
    @cloud_name = node[:workorder][:cloud][:ciName]
    Chef::Log.info("@cloud_name : #{@cloud_name}")
    
    #extract cloud provider 'Openstack/Azure' from compute service string {"prod-cdc5":{"ciClassName":"cloud.service.Openstack"}}
    Chef::Log.info("node[:workorder][:services][:compute] = #{node[:workorder][:services][:compute].to_json}")
    @cloud_provider = node[:workorder][:services][:compute][@cloud_name][:ciClassName].gsub("cloud.service.","").downcase.split(".").last
    Chef::Log.info("Cloud Provider: #{@cloud_provider}")
    
    # Replica distribution varies based on cloud provider. For ex. with 'Openstack' cloud provider, we distribute replicas across clouds and witn 'Azure', 
    # replicas are distributes across domains. If no cloud provider in payload, then error out. 
    if @cloud_provider == nil || @cloud_provider.empty?
      raise "Replica distribution varies based on cloud provider and hence cloud provider must be present in compute service at cloud level."
    end
    #get the current node's compute
    managedVia_compute = node.workorder.payLoad.ManagedVia[0]
   
    case @cloud_provider
      when /azure/
      # get zone info for 'azure' cloud provider
        zone = (managedVia_compute[:ciAttributes].has_key?"zone")?JSON.parse(managedVia_compute[:ciAttributes][:zone]):{}
        Chef::Log.info("zone = #{zone.to_json}")
        if zone == nil
          raise "Missing zone information for azure cloud at compute."
        end
        @fault_domain = zone['fault_domain']
        @update_domain = zone['update_domain']
        if @fault_domain == nil || @fault_domain.to_s.empty?
          raise "Missing fault_domain information for azure cloud at compute."
        end
        if @update_domain == nil || @update_domain.to_s.empty?
          raise "Missing update_domain information for azure cloud at compute."
        end
        @zone_name = "#{@fault_domain}___#{@update_domain}"
        Chef::Log.info("@zone_name : #{@zone_name}")
        # in case of azure, key -> zone i.e. fault_domain_update_domain. ex 1_1
        @zone_to_compute_ip_map = get_compute_zone_to_compute_ip_map(node)
      else #/vagrant/
        # in case of other (openstack), key -> cloud_name ex. prod-cdc5
        @zone_to_compute_ip_map = get_cloud_name_to_compute_ip_map(node)
    end
  end

  # get cloud name and computes information from the payload
  # where key-> <cloud_name> & value-> list of ips
  # For ex. {"prod-cdc5":[ip1, ip2],"prod-cdc6":[ip3, ip4]}
  def get_cloud_name_to_compute_ip_map(node)
    clouds = get_clouds_payload(node)
    Chef::Log.info("clouds = #{clouds.to_json}")
   
    #cloud_id_to_name_map=> {'35709237':'cloud1','35709238':'cloud2'}
    cloud_id_to_name_map = Hash.new
    clouds.each { |cloud|
      cloud_id_to_name_map[cloud[:ciId].to_s] = cloud[:ciName]
    }
    Chef::Log.info "cloud_id_to_name_map = #{cloud_id_to_name_map.to_json}"

    cloud_name_to_ip_map = Hash.new()
    computes = get_computes_payload(node)
    computes.each do |compute|
      
      # compute[:ciName] == nil meaning compute has not provisioned yet
      next if compute[:ciName].nil?
      # Example compute[:ciName]:  compute-35709237-2

      # extract cloud_id from compute ciName. i.e. cloud_id = 35709237
      cloud_id = compute[:ciName].split('-').reverse[1].to_s

      # get cloud_name for cloud_id from cloud_id_to_name_map. i.e. cloud_name = cloud1
      cloud_name = cloud_id_to_name_map[cloud_id]

      if (cloud_name_to_ip_map[cloud_name] == nil)
        cloud_name_to_ip_map[cloud_name] = Array.new
      end

      # add private_ip to cloud_name_to_ip_map
      if compute[:ciAttributes][:private_ip] != nil
        cloud_name_to_ip_map[cloud_name].push(compute[:ciAttributes][:private_ip])
      end
    end
    Chef::Log.info("cloud_name_to_ip_map: #{cloud_name_to_ip_map.to_json}")
    return cloud_name_to_ip_map
  end

  # get domain and computes map information from the payload
  # where key-> <fauld_domain>_<update_domain> & value-> list of ips
  # For ex. {"1_1":[ip1, ip2],"1_2":[ip3, ip4]}
  def get_compute_zone_to_compute_ip_map(node)
    #define map with key as <fault_domain>_<update_domain>. ex=>1_1, 1_2 and value=>[ip1,ip2]
    zone_to_ips_map = Hash.new
    computes = get_computes_payload(node)

    computes.each do |compute|

      # each compute's ciAttribute must have zone info like "zone": "{\"fault_domain\":0,\"update_domain\":0}"
      if zone_info_missing?(compute)
        raise "Zone attrribute with fault_domain/update_domain information is required."
      end

      # get <fault_domain>_<update_domain> e. 0_1
      zone_info = get_zone_info(compute)

      # add zone_info as key if doesn't exists
      ip = compute[:ciAttributes][:private_ip]
      if !zone_to_ips_map.has_key?(zone_info)
        zone_to_ips_map[zone_info] = []
      end
      # add ip to zone_info
      zone_to_ips_map[zone_info].push ip
    end
    Chef::Log.info("zone_to_ips_map = #{zone_to_ips_map.to_json}")
    return zone_to_ips_map
  end

  def get_zone_to_compute_ip_map()
    return @zone_to_compute_ip_map
  end

  # check if 'zone' attribute and/or its details are missing at compute
  def zone_info_missing?(compute)
    # check if 'zone' attribute is missing at compute
    if compute['ciAttributes']['zone'].nil?
      return true
    end
    # check if 'fault_domain' or 'update_domain' attribute is null/empty at
    zone  = JSON.parse(compute['ciAttributes']['zone'])
    if zone['fault_domain'].nil? || zone['fault_domain'] == '' || zone['update_domain'].nil? || zone['update_domain'] == ''
      return true
    end
    return false
  end

  # get <fault_domain>_<update_domain> from compute
  def get_zone_info(compute)
    zone  = JSON.parse(compute['ciAttributes']['zone'])
    return "#{zone['fault_domain']}_#{zone['update_domain']}"
  end

  # get compute payload from workorder
  def get_computes_payload(node)
    return node.workorder.payLoad.has_key?("RequiresComputes") ? node.workorder.payLoad.RequiresComputes : node.workorder.payLoad.computes
  end
  
  def get_clouds_payload(node)
    return node.workorder.payLoad.has_key?("Clouds") ? node.workorder.payLoad.Clouds : nil
  end
end

