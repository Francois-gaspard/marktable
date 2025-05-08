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

    chain :ignore_headers do 
      @headers = false
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
        input = parse_capybara_html(input)
        format = :html
      end

      # Handle Nokogiri elements
      if nokogiri?(input)
        input = input.to_html
        format = :html
      end

      # Pass headers option if it was specified in the chain
      options = { type: format }
      options[:headers] = @headers unless @headers.nil?
      Marktable::Table.new(input, **options)
    end

    def html?(data)
      nokogiri?(data) || capybara?(data)
    end

    def parse_capybara_html(data)
      rows = data.all('tr').map do |row|
        cells = row.all('th,td').map do |cell|
          cell_text = cell.text.tr("\n", ' ').strip
          cell_type = cell.tag_name
          "<#{cell_type}>#{cell_text}</#{cell_type}>"
        end
        "<tr>#{cells.join}</tr>"
      end
      "<table>#{rows.join}</table>"
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
      else
        html?(data) ? :html : :markdown
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
