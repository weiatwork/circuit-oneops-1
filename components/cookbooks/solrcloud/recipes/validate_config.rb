def custom_artifact_config_provided?
  release_urlbase = node['solr_custom_params']['release_urlbase'] || ""
  snapshot_urlbase = node['solr_custom_params']['snapshot_urlbase'] || ""
  solr_custom_comp_artifact = node['solr_custom_params']['solr_custom_comp_artifact'] || ""
  Chef::Log.info("release_urlbase=#{release_urlbase}")
  Chef::Log.info("snapshot_urlbase=#{snapshot_urlbase}")
  Chef::Log.info("solr_custom_comp_artifact=#{solr_custom_comp_artifact}")
  return !release_urlbase.empty? && !snapshot_urlbase.empty? && !solr_custom_comp_artifact.empty?
end

if node.workorder.has_key?("rfcCi")
  ci = node.workorder.rfcCi.ciAttributes;
else
  ci = node.workorder.ci.ciAttributes;
end

# get the url_max_requests_per_sec_map where key is url pattern & value is maxRequestPerSec
# Append map index to value so that in case of multiple filters, each filter can have different name
# For ex. for each url patter the filter name will be as DoDFilter0, DoDFilter1..
# Also validate url_max_requests_per_sec_map for any empty key or/and value and non mueric value
solr_custom_params = node['solr_custom_params']
jetty_filter_url = (solr_custom_params.has_key?'jetty_filter_url')?solr_custom_params['jetty_filter_url']:""
jetty_filter_class = (solr_custom_params.has_key?'solr_dosfilter_class')?solr_custom_params['solr_dosfilter_class']:""
node.set['url_max_requests_per_sec_map'] = Hash.new() 
if ci.has_key?("url_max_requests_per_sec_map") 
  url_max_requests_per_sec_map = JSON.parse(ci['url_max_requests_per_sec_map'])
  url_max_requests_per_sec_map.each_with_index do |(key, value), index|
    if key == nil || key.strip.empty?
      puts "***FAULT:FATAL=Invalid url pattern for DoSFilter : #{key}"
      e = Exception.new("no backtrace")
      e.set_backtrace("")
      raise e  
    elsif value == nil || value.match(/\A[+-]?\d+?\Z/) == nil
      puts "***FAULT:FATAL=Invalid maxRequestsPerSec #{value} for DoSFilter url pattern #{key}"
      e = Exception.new("no backtrace")
      e.set_backtrace("")
      raise e  
    end
    url_max_requests_per_sec_map[key.strip] = "#{value.strip}:DoSFilter#{index}"
  end
  node.set['url_max_requests_per_sec_map'] = url_max_requests_per_sec_map
end

# if maxRequestsPerSec is provided, then DoS filter url must be provided
if !node['url_max_requests_per_sec_map'].empty?
  if jetty_filter_url.empty?
    error = "URL for Jetty-QoS/DoS-custom-filter must be provided if you are providing URL-patterns with maxRequestsPerSec attributes"
    puts "***FAULT:FATAL=#{error}"
    raise e
  elsif jetty_filter_class.empty?
    error = "DoS filter class for Jetty-QoS/DoS-custom-filter must be provided if you are providing URL-patterns with maxRequestsPerSec attributes"
    puts "***FAULT:FATAL=#{error}"
    raise e
  end
end

solr_custom_comp_version = node['solr_custom_component_version']
if solr_custom_comp_version == nil || solr_custom_comp_version.empty?
  Chef::Log.warn("solr_custom_comp_version is not selected, hence solrcloud will be setup without custom configuration. ")
  return
end
puts "custom_artifact_config_provided=#{custom_artifact_config_provided?}"
if !custom_artifact_config_provided?
    msg = "solr_custom_comp_version version selected but some of the required configs (solr_custom_comp_artifact, release_urlbase & snapshot_urlbase) is not provided with solr cloud service."
    puts "***FAULT:FATAL=#{msg}"
    raise msg
end
solr_custom_comp_artifact = node['solr_custom_params']['solr_custom_comp_artifact']

artifact_descriptor = "#{solr_custom_comp_artifact}:#{solr_custom_comp_version}:jar"

if (solr_custom_comp_version =~ /SNAPSHOT/)
  artifact_urlbase = node['solr_custom_params']['snapshot_urlbase']
else
  artifact_urlbase = node['solr_custom_params']['release_urlbase']
end

solr_custom_comp_url, solr_custom_comp_version = SolrCustomComponentArtifact::get_artifact_url(artifact_descriptor, artifact_urlbase)

Chef::Log.info( "solr_custom_comp_url - #{solr_custom_comp_url} and solr_custom_comp_version -  #{solr_custom_comp_version}")

if (solr_custom_comp_version.to_s =~ /SNAPSHOT/)
  solr_custom_comp_version = solr_custom_comp_version.gsub('-SNAPSHOT', '')
end

solr_custom_comp_jar = "solr-custom-components-#{solr_custom_comp_version}.jar"
solr_plugins_dir = "/app/solr#{node['solrmajorversion']}/plugins"

["#{solr_plugins_dir}"].each { |dir|
  Chef::Log.info("creating #{dir}")
  directory dir do
    owner node['solr']['user']
    group node['solr']['user']
    mode "0755"
    recursive true
    action :create
  end
}

# Fetch the custom solr component artifact
remote_file "#{solr_plugins_dir}/#{solr_custom_comp_jar}" do
  user 'app'
  group 'app'
  source solr_custom_comp_url
  only_if { ::File.directory?("#{solr_plugins_dir}") }
end