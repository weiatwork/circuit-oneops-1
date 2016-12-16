
def get_attribute_value(attr_name)
	node.workorder.rfcCi.ciBaseAttributes.has_key?(attr_name)? node.workorder.rfcCi.ciBaseAttributes[attr_name] : node.tomcat[attr_name]
end

def tom_ver
	major_version = node.workorder.rfcCi.ciAttributes.version.gsub(/\..*/,"")
	tomcat_version_name = "tomcat"+major_version
	return tomcat_version_name
end
