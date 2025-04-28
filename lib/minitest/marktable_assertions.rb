# frozen_string_literal: true

require 'minitest/assertions'
require 'marktable'

module Minitest
  module MarktableAssertions
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
        "Expected markdown tables to differ, but they match:\n\n" \
        "#{actual_data.to_md}"
      end
      
      refute_equal expected_data.to_a, actual_data.to_a, message
    end
    
    private
    
    def parse_input(input, format = nil)
      return input if input.is_a?(::Marktable::Table)
      
      ::Marktable::Table.new(input, type: format)
    end
    
    def infer_format(data)
      case data
      when Array
        :array
      when CSV::Table
        :csv
      when ::Marktable::Table
        :markdown
      else
        :markdown
      end
    end
    
    def format_failure_message(expected_data, actual_data)
      "Expected markdown table to match:\n\n" \
      "Expected:\n#{expected_data.to_md}\n\n" \
      "Actual:\n#{actual_data.to_md}\n\n" \
      "Parsed expected data: #{expected_data.to_a.inspect}\n" \
      "Parsed actual data: #{actual_data.to_a.inspect}"
    end
  end
end

# Add Minitest::MarktableAssertions to Minitest::Test
module Minitest
  class Test
    include MarktableAssertions
  end
end
