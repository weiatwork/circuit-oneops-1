require 'json'
require 'nokogiri'

def validate_xml(xml_file)
  begin
    xml = File.read(xml_file)
    doc = Nokogiri::XML(xml) { |config| config.strict }
  rescue Nokogiri::XML::SyntaxError => e
    raise "caught exception in file #{xml_file} : #{e}"
  end
end

def execute_command(cmd)
  puts "executing command #{cmd}"
  result = `#{cmd}`
  if $? != 0
    raise "Error while executing command #{cmd}"
  end
  puts "command output = #{result}"
  return result.split("\n")
end

def get_file_path(regex_path, multiple_allowed=false)
  files = execute_command("find #{regex_path}")
  if files.size == 0
    raise "No solr service found"
  elsif !multiple_allowed && files.size > 1
    raise "Multiple solr service files found"
  end
  return multiple_allowed ? files : files[0]
end

def validate_monitor_status(monitor_path, args, expected_status)
  cmd = "#{monitor_path} #{args.join(' ')}"
  result = execute_command(cmd)
  actual_status = nil
  result.each do |s|
    if s.include?("up=")
      actual_status = s.split("up=")[1].to_i
    end
  end 
  if actual_status != expected_status
    raise "#{monitor_path} monitor status #{actual_status} does not match with expected status #{expected_status}"
  end
end

def validate_property_file(file_path)
  result = File.read(file_path).split("\n")
  result.each do |prop_string|
    prop_string.strip!
    next if prop_string.empty?
    if (prop_string[0] != ?# and prop_string[0] != ?=)
      prop = prop_string.split("=")
      if prop.size != 2
        raise "Invalid property #{prop_string} in file #{file_path}"
      end
    end
  end
end

#port = "8983"
port = $node['solrcloud']['port_no']
#jolokia_port = "17330"
jolokia_port = $node['solrcloud']['jolokia_port']

# validate solr service 
service_file = get_file_path('/etc/init.d/solr[0-9]*')
puts "solr service file = #{service_file}"
solr_monitor_file = get_file_path('/opt/nagios/libexec/check_solrprocess.sh')
puts "solr_monitor_file = #{solr_monitor_file}"
validate_monitor_status(solr_monitor_file, [port], 100)

solr_mbeanstat_file = get_file_path('/opt/nagios/libexec/check_solr_mbeanstat.rb')
execute_command("#{solr_mbeanstat_file} MemoryStats #{port}")
execute_command("#{solr_mbeanstat_file} ReplicaStatus #{port}")
execute_command("#{solr_mbeanstat_file} JVMThreadCount #{jolokia_port}")
execute_command("#{solr_mbeanstat_file} HeapMemoryUsage #{jolokia_port}")

solr_monitor_folder = "/opt/solr/solrmonitor"
solr_monitor_script = "metrics-tool.rb"
solr_monitor_file = get_file_path("#{solr_monitor_folder}/#{solr_monitor_script}")
execute_command("cd /opt/solr/solrmonitor")
get_file_path("/opt/solr/log/medusa_stats.log")
get_file_path("/opt/solr/log/jmx_medusa_stats.log")

zk_monitor_file = get_file_path('/opt/nagios/libexec/check_solr_zk_conn.sh')
validate_monitor_status(zk_monitor_file, [], 100)

log4j_property_files = get_file_path('/app/solrdata*/ -name log4j.properties', true)
puts "log4j_property_files = #{log4j_property_files}"
log4j_property_files.each do |file|
  validate_property_file(file)
end

xml_files = get_file_path('/app/solr[0-9]*/server/solr -name solr*.xml | grep -v /configsets/', true)
xml_files.each do |file|
  puts "Validating xml file :  #{file}"
  validate_xml(file)
end
