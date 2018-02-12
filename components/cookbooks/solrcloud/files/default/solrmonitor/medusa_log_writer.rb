class MedusaLogWriter

  attr_reader :name
  attr_writer :logger
  attr_accessor :fields

  CONST_CLUSTER_SUMMARY = 'solr_cluster_summary'

  def initialize(logger)
    @logger = logger
  end

  def write_medusa_log(name, fields, time = Time.now)
    @name = name
    @fields = fields
    @time = time
    fields_array = []
    @fields.each { |k, v| fields_array << "#{k}=#{v.nil? ? MISSING_FIELD_VALUE : v}" }
    # Removing the time in nanoseconds as the timestamp which is put in log file was conflicting with telegraf timestamp and was giving missing data points as date consolidated by telegraf was becoming invalid.
    msg = "#{@name} #{fields_array.join(',')}"
    @logger.info(msg)
    msg
  end
end
