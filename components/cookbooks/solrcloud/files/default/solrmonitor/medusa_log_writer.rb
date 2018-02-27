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
    # The nanoseconds timestamp in the log file was somehow conflicting with telegraf's timestamp.
    # And it was causing missed data points in Medusa because telegraf was taking wrong time in the past.
    # So below line was commented to avoid writing timestamps altogether.
    # msg = "#{@name} #{fields_array.join(',')} #{@time.to_i}#{@time.usec}000"
    msg = "#{@name} #{fields_array.join(',')}"
    @logger.info(msg)
    msg
  end
end
