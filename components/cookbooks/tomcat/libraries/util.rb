
def get_attribute_value(attr_name)
	node.workorder.rfcCi.ciBaseAttributes.has_key?(attr_name)? node.workorder.rfcCi.ciBaseAttributes[attr_name] : node.tomcat[attr_name]
end

def tom_ver
	case node.tomcat.install_type
	when "repository"
		tomcat_version_name = "tomcat"
	when "binary"
		tomcat_service_name = "tomcat"+node[:tomcat][:version][0,1]
	end
	return tomcat_version_name
end
