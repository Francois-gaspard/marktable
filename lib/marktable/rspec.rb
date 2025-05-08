# frozen_string_literal: true

require 'capybara'
require 'nokogiri'
require 'marktable'

# Register the matchers if RSpec is defined
if defined?(RSpec)
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

      # Handle both Capybara::Node::Element and Capybara::Node::Simple
      if capybara?(input)
        # Convert Capybara element to Nokogiri element or HTML
        input = input.native
        format = :html
      end

      # Handle Nokogiri elements
      if nokogiri?(input)
        input = input.to_html
        format = :html
      end

      Marktable::Table.new(input, type: format)
    end

    def html?(data)
      nokogiri?(data) || capybara?(data)
    end

    def capybara?(data)
      defined?(Capybara::Node::Base) && data.is_a?(Capybara::Node::Base) ||
        defined?(Capybara::Node::Simple) && data.is_a?(Capybara::Node::Simple) ||
        defined?(Capybara::Node::Element) && data.is_a?(Capybara::Node::Element)
    end

    def nokogiri?(data)
      defined?(Nokogiri::XML::Node) && data.is_a?(Nokogiri::XML::Node)
    end

    def infer_format(data)
      case data
      when Array
        :array
      when CSV::Table
        :csv
      when Marktable::Table
        :markdown
      when html?(data)
        :html
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
