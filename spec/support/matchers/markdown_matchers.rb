# frozen_string_literal: true

RSpec::Matchers.define :match_markdown do |expected_markdown|
  match do |actual|
    # Handle markdown string, array of hashes, and Marktable::Table objects
    actual_data = case actual
                  when String
                    Marktable.parse(actual)
                  when Marktable::Table
                    actual.to_a
                  else
                    actual
                  end

    expected_data = Marktable.parse(expected_markdown)
    
    # Normalize data by trimming whitespace in cell values
    normalize = ->(data) {
      data.map do |row|
        if row.is_a?(Hash)
          row.transform_values { |v| v.to_s.strip }
        else
          row.map { |v| v.to_s.strip }
        end
      end
    }
    
    actual_data = normalize.call(actual_data)
    expected_data = normalize.call(expected_data)
    
    # Compare the parsed data structures
    actual_data == expected_data
  end

  failure_message do |actual|
    # Parse data for comparison output
    actual_data = case actual
                  when String
                    Marktable.parse(actual)
                  when Marktable::Table
                    actual.to_a
                  else
                    actual
                  end
    expected_data = Marktable.parse(expected_markdown)

    # Format both tables properly for display
    actual_formatted = Marktable.table(actual_data).to_s
    expected_formatted = Marktable.table(expected_data).to_s

    "Expected markdown table to match:\n\n" \
    "Expected:\n#{expected_formatted}\n\n" \
    "Actual:\n#{actual_formatted}\n\n" \
    "Parsed expected data: #{expected_data.inspect}\n" \
    "Parsed actual data: #{actual_data.inspect}"
  end

  failure_message_when_negated do |actual|
    # Parse data for comparison output
    actual_data = case actual
                  when String
                    Marktable.parse(actual)
                  when Marktable::Table
                    actual.to_a
                  else
                    actual
                  end
    
    # Generate properly formatted markdown for display
    actual_formatted = Marktable.table(actual_data).to_s

    "Expected markdown tables to differ, but they match:\n\n" \
    "#{actual_formatted}"
  end
end
