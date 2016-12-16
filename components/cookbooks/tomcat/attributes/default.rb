# Tomcat
major_version = node.workorder.rfcCi.ciAttributes.version.gsub(/\..*/,"")
tomcat_version_name = "tomcat"+major_version
default["tomcat"]["port"] = 8080
default["tomcat"]["server_port"] = 8005
default["tomcat"]["ssl_port"] = 8443
default["tomcat"]["ajp_port"] = 8009
default["tomcat"]["java_options"] = "-Djava.awt.headless=true"
default["tomcat"]["use_security_manager"] = false
default["tomcat"]["webapp_install_dir"] = "/var/lib/#{tomcat_version_name}/webapps"
default["tomcat"]["stop_time"] = 45
# Default thread pool configuration
default['tomcat']['executor']['executor_name'] = 'tomcatThreadPool'
default['tomcat']['executor']['max_threads'] = '50'
default['tomcat']['executor']['min_spare_threads'] = '25'
# Default TLS Ciphers.
# Note the cipher list is not updated if different TLS versions are enabled/disabled. Tomcat chooses the appropriate ciphers from this list based on the TLS versions enabled.
default['tomcat']['connector']['ssl_configured_ciphers'] = 'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_256_CBC_SHA256,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_256_CBC_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_CAMELLIA_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_128_CBC_SHA256,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA,TLS_RSA_WITH_AES_128_GCM_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_CAMELLIA_128_CBC_SHA,TLS_DHE_RSA_WITH_SEED_CBC_SHA,TLS_RSA_WITH_SEED_CBC_SHA'

# private
#
# set["global"]["base"] = [node.tomcat.webapp_install_dir,node.workorder.rfcCi.ciName].join('/')
# set["global"]["nspath"] = node.workorder.rfcCi.nsPath
# set["tomcat"]["version"] = "6.0.32"
# set["tomcat"]["home"] = "#{global.base}/software/apache-tomcat-#{tomcat.version}"
# set["tomcat"]["base"] = "#{global.base}/run"

set["java"]["java_home"] = "/usr"

case platform
when "centos","redhat","fedora"
  set["tomcat"]["user"] = "tomcat"
  set["tomcat"]["group"] = "tomcat"
  set["tomcat"]["home"] = "/usr/share/#{tomcat_version_name}"
  set["tomcat"]["base"] = "/usr/share/#{tomcat_version_name}"
  set["tomcat"]["config_dir"] = "/etc/#{tomcat_version_name}"
  set["tomcat"]["log_dir"] = "/var/log/#{tomcat_version_name}"
  set["tomcat"]["tmp_dir"] = "/var/cache/#{tomcat_version_name}/temp"
  set["tomcat"]["work_dir"] = "/var/cache/#{tomcat_version_name}/work"
  set["tomcat"]["context_dir"] = "#{tomcat["config_dir"]}/Catalina/localhost"
  set["tomcat"]["webapp_dir"] = "/var/lib/#{tomcat_version_name}/webapps"
when "debian","ubuntu"
  set["tomcat"]["user"] = "#{tomcat_version_name}"
  set["tomcat"]["group"] = "#{tomcat_version_name}"
  set["tomcat"]["home"] = "/usr/share/#{tomcat_version_name}"
  set["tomcat"]["base"] = "/var/lib/#{tomcat_version_name}"
  set["tomcat"]["config_dir"] = "/etc/#{tomcat_version_name}"
  set["tomcat"]["log_dir"] = "/var/log/#{tomcat_version_name}"
  set["tomcat"]["tmp_dir"] = "/tmp/#{tomcat_version_name}-tmp"
  set["tomcat"]["work_dir"] = "/var/cache/#{tomcat_version_name}"
  set["tomcat"]["context_dir"] = "#{tomcat["config_dir"]}/Catalina/localhost"
  set["tomcat"]["webapp_dir"] = "/var/lib/#{tomcat_version_name}/webapps"
else
  set["tomcat"]["user"] = "#{tomcat_version_name}"
  set["tomcat"]["group"] = "#{tomcat_version_name}"
  set["tomcat"]["home"] = "/usr/share/#{tomcat_version_name}"
  set["tomcat"]["base"] = "/var/lib/#{tomcat_version_name}"
  set["tomcat"]["config_dir"] = "/etc/#{tomcat_version_name}"
  set["tomcat"]["access_log_dir"] = "/var/log/#{tomcat_version_name}"
  set["tomcat"]["log_dir"] = "/var/log/#{tomcat_version_name}"
  set["tomcat"]["tmp_dir"] = "/tmp/#{tomcat_version_name}-tmp"
  set["tomcat"]["work_dir"] = "/var/cache/#{tomcat_version_name}"
  set["tomcat"]["context_dir"] = "#{tomcat["config_dir"]}/Catalina/localhost"
  set["tomcat"]["webapp_dir"] = "/var/lib/#{tomcat_version_name}/webapps"
end
