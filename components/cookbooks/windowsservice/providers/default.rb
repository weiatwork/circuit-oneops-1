WINDOWS_SERVICE_PROPERTIES = {
  'service_name'          =>  'service_name',
  'service_display_name'  =>  'display_name',
  'startup_type'          =>  'start_type',
  'path'                  =>  'binary_path_name',
  'username'              =>  'service_start_name',
  'password'              =>  'password'
}

SERVICE_STARTUP_TYPE = {
  'auto start'   => 2,
  'demand start' => 3,
  'disabled'     => 4
}

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = new_resource.class.new(new_resource.name)
  @service_windows = OO::WindowsService.new

  @current_resource.service_name(new_resource.service_name)

  if @service_windows.service_exists?(@current_resource.service_name)
    service_attributes = @service_windows.get_windows_service_attribute(@current_resource.service_name)
    @current_resource.exists = true
    @current_resource.status = @service_windows.service_status(@current_resource.service_name)
    WINDOWS_SERVICE_PROPERTIES.each_key do |property_name|
      @current_resource.send(property_name, service_attributes[property_name])
    end
  end
end

action :create do
  if @service_windows.service_exists?(new_resource.service_name)
    Chef::Log.info "The service #{new_resource.service_name} already exist."
  else
    @service_windows.create_service( get_windows_service_attributes )
    Chef::Log.info "Successfully installed the service #{new_resource.service_name}."
    new_resource.updated_by_last_action(true)
  end
end

action :update do
  if @current_resource.exists
    if service_need_update
      @service_windows.update_service( get_windows_service_attributes )
      Chef::Log.info "Successfully updated the service #{new_resource.service_name}."
    else
      Chef::Log.info "#{new_resource.service_name} is already up to date. Nothing to do."
    end
  else
    Chef::Log.info "#{new_resource.service_name} does not exist. Nothing to do."
  end
end

action :start do
  if @current_resource.exists
    if @current_resource.status != 'running'
      windows_service new_resource.service_name do
        action :start
      end
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.info "#{new_resource.service_name} is already runnings. Nothing to do."
    end
  else
    Chef::Log.info "#{new_resource.service_name} does not exist."
  end
end

action :stop do
  if @current_resource.exists
    if @current_resource.status == 'running'
      windows_service new_resource.service_name do
        action :stop
      end
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.info "#{new_resource.service_name} is not running. Nothing to do."
    end
  else
    Chef::Log.info "#{new_resource.service_name} does not exist."
  end
end

def get_windows_service_attributes
  attributes = {}
  WINDOWS_SERVICE_PROPERTIES.each_pair do |property_name, value_property_name|
    attributes[value_property_name] = new_resource.send(property_name)
  end
  attributes['start_type'] = SERVICE_STARTUP_TYPE[attributes['start_type']]
  attributes
end

def service_need_update
  resource_need_update = false
  WINDOWS_SERVICE_PROPERTIES.each_key do |property_name|
    resource_need_update = true if @current_resource.send(property_name) != new_resource.send(property_name) && property_name != 'password'
  end
  resource_need_update
end
