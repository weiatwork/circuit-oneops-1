def custom_artifact_config_provided?
  release_urlbase = node['solr_custom_params']['release_urlbase'] || ""
  snapshot_urlbase = node['solr_custom_params']['snapshot_urlbase'] || ""
  solr_custom_comp_artifact = node['solr_custom_params']['solr_custom_comp_artifact'] || ""
  return !release_urlbase.empty? && !snapshot_urlbase.empty? && !solr_custom_comp_artifact.empty?
end

solr_custom_params = node['solr_custom_params']

block_expensive_queries_class = solr_custom_params['block_expensive_queries_class'] || ""
if node["block_expensive_queries"] == "true" && (!custom_artifact_config_provided? || block_expensive_queries_class.empty?)
    msg = "Option enable block_expensive_queries is selected but block_expensive_queries_class is not provided. To enable block_expensive_queries make sure block_expensive_queries_class, solr_custom_comp_artifact, release_urlbase & snapshot_urlbase is provided with solr cloud service or disable block_expensive_queries option"
    puts "***FAULT:FATAL=#{msg}"
    e = Exception.new(msg)
    raise e
end

slow_query_logger_class = solr_custom_params['slow_query_logger_class'] || ""
slow_query_logger = solr_custom_params['slow_query_logger'] || ""
if node["enable_slow_query_logger"] == "true" && (!custom_artifact_config_provided? || slow_query_logger_class.empty? || slow_query_logger.empty?)
    msg = "Option enable enable_slow_query_logger is selected but slow_query_logger_class is not provided. To enable enable_slow_query_logger make sure slow_query_logger_class, slow_query_logger, solr_custom_comp_artifact, release_urlbase & snapshot_urlbase is provided with solr cloud service or disable enable_slow_query_logger option"
    puts "***FAULT:FATAL=#{msg}"
    e = Exception.new(msg)
    raise e
end

query_source_tracker_class = solr_custom_params['query_source_tracker_class'] || ""
if node["enable_query_source_tracker"] == "true" && (!custom_artifact_config_provided? || query_source_tracker_class.empty?)
    msg = "Option enable enable_query_source_tracker is selected but query_source_tracker_class is not provided. To enable enable_query_source_tracker make sure query_source_tracker_class, solr_custom_comp_artifact, release_urlbase & snapshot_urlbase is provided with solr cloud service or disable enable_query_source_tracker option"
    puts "***FAULT:FATAL=#{msg}"
    e = Exception.new(msg)
    raise e
end