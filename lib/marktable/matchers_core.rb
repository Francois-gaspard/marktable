# frozen_string_literal: true

require 'marktable'

module Marktable
  # Core functionality for markdown table matching shared by RSpec and Minitest
  module MatchersCore
    # Parse input data into a Marktable::Table
    def parse_input(input, format = nil)
      return input if input.is_a?(::Marktable::Table)
      
      ::Marktable::Table.new(input, type: format)
    end
    
    # Infer the format of the input data
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
    
    # Format a failure message for comparison failures
    def format_failure_message(expected_data, actual_data)
      "Expected markdown table to match:\n\n" \
      "Expected:\n#{expected_data.to_md}\n\n" \
      "Actual:\n#{actual_data.to_md}\n\n" \
      "Parsed expected data: #{expected_data.to_a.inspect}\n" \
      "Parsed actual data: #{actual_data.to_a.inspect}"
    end
    
    # Format a negated failure message
    def format_negated_failure_message(actual_data)
      "Expected markdown tables to differ, but they match:\n\n" \
      "#{actual_data.to_md}"
    end
  end
end
