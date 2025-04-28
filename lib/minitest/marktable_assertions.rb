# frozen_string_literal: true

require 'minitest/assertions'
require 'marktable'
require_relative '../marktable/matchers_core'

module Minitest
  module MarktableAssertions
    include ::Marktable::MatchersCore
    
    # Asserts that two markdown tables or equivalent data structures match.
    #
    # @param expected_markdown [String, Array] The expected markdown table or data
    # @param actual [String, Array, Marktable::Table] The actual data to compare
    # @param format [Symbol] The format of the actual data (:markdown, :array, :html)
    # @param msg [String] Custom message on failure
    def assert_markdown_match(expected_markdown, actual, format = nil, msg = nil)
      # Format might be provided through the FormatInfo mechanism
      if format.nil? && defined?(Minitest::MarktableSupport::FormatInfo)
        format = Minitest::MarktableSupport::FormatInfo.get_format(actual.object_id)
      end
      
      expected_data = parse_input(expected_markdown, :markdown)
      format ||= infer_format(actual)
      actual_data = parse_input(actual, format)
      
      message = message(msg) do
        format_failure_message(expected_data, actual_data)
      end
      
      assert_equal expected_data.to_a, actual_data.to_a, message
    end
    
    # Refutes that two markdown tables or equivalent data structures match.
    #
    # @param expected_markdown [String, Array] The expected markdown table or data
    # @param actual [String, Array, Marktable::Table] The actual data to compare
    # @param format [Symbol] The format of the actual data (:markdown, :array, :html)
    # @param msg [String] Custom message on failure
    def refute_markdown_match(expected_markdown, actual, format = nil, msg = nil)
      # Format might be provided through the FormatInfo mechanism
      if format.nil? && defined?(Minitest::MarktableSupport::FormatInfo)
        format = Minitest::MarktableSupport::FormatInfo.get_format(actual.object_id)
      end
      
      expected_data = parse_input(expected_markdown, :markdown)
      format ||= infer_format(actual)
      actual_data = parse_input(actual, format)
      
      message = message(msg) do
        format_negated_failure_message(actual_data)
      end
      
      refute_equal expected_data.to_a, actual_data.to_a, message
    end
  end
end

# Add Minitest::MarktableAssertions to Minitest::Test
module Minitest
  class Test
    include MarktableAssertions
  end
end
