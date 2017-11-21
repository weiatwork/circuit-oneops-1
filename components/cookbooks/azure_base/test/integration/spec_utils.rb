class SpecUtils
  def initialize(node)
    @node = node
  end

  def get_cloud_name
    cloud_name = @node['workorder']['cloud']['ciName']
  end

  def get_provider
    cloud_name = get_cloud_name
    provider = @node['workorder']['services']['compute'][cloud_name]['ciClassName'].gsub("cloud.service.","").downcase.split(".").last
  end

  def get_cloud_service
    lb_service_type = @node['lb']['lb_service_type']
    cloud_service = @node['workorder']['services'][lb_service_type][get_cloud_name]

    cloud_service
  end
end
