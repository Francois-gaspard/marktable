require 'rspec'
require_relative '../lib/marktable'

# Load custom matchers
Dir[File.join(File.dirname(__FILE__), "support/matchers/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  
  config.filter_run_when_matching focus: true
end
