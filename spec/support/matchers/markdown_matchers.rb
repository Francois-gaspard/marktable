# frozen_string_literal: true

require 'capybara'
require 'nokogiri'

RSpec::Matchers.define :match_markdown do |expected_markdown|
  chain :with_format do |format|
    @format = format
  end

  match do |actual|
    @expected_data = parse_input(expected_markdown, :markdown)
    @format ||= infer_format(actual)
    @actual_data = parse_input(actual, @format)

    # Compare data using to_a for consistent comparison
    @actual_data.to_a == @expected_data.to_a
  end

  failure_message do
    format_failure_message(@expected_data, @actual_data)
  end

  failure_message_when_negated do
    "Expected markdown tables to differ, but they match:\n\n" \
    "#{@actual_data.to_md}"
  end

  private

  def parse_input(input, format = nil)
    return input if input.is_a?(Marktable::Table)

    Marktable::Table.new(input, type: format)
  end

  def infer_format(data)
    case data
    when Array
      :array
    when CSV::Table
      :csv
    when Marktable::Table
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
