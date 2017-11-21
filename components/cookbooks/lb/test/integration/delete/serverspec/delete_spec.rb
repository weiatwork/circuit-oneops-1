CIRCUIT_PATH = '/opt/oneops/inductor/circuit-oneops-1'.freeze
COOKBOOKS_PATH = "#{CIRCUIT_PATH}/components/cookbooks"
AZURE_TESTS_PATH = "#{COOKBOOKS_PATH}/azure_lb/test/integration/delete/serverspec/tests"
AZURE_GATEWAY_TESTS_PATH = "#{COOKBOOKS_PATH}/azuregateway/test/integration/delete/serverspec/tests"

require "#{CIRCUIT_PATH}/components/spec_helper.rb"
require "#{COOKBOOKS_PATH}/azure_base/test/integration/spec_utils"

provider = SpecUtils.new($node).get_provider
if provider =~ /azure/
  require "#{COOKBOOKS_PATH}/azure_base/test/integration/azure_spec_utils"

  cloud_service = SpecUtils.new($node).get_cloud_service['ciClassName'].split('.').last.downcase
  case cloud_service
  when /azure_lb/
    Dir.glob("#{AZURE_TESTS_PATH}/*.rb").each {|test| require test}
  when /azuregateway/
    Dir.glob("#{AZURE_GATEWAY_TESTS_PATH}/*.rb").each {|test| require test}
  end
end
