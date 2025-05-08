# frozen_string_literal: true

require 'nokogiri'
require_relative 'base'

module Marktable
  module Tables
    class HTML
      private attr_reader :table

      def initialize(html_data, headers = nil)
        @table = extract_table_node(html_data)
        @headers_flag = headers
      end

      def parse
        return Tables::Base.blank if table.nil? || rows.empty?

        if has_headers?
          headers = extract_row_cells(first_row)
          data_rows = rows[1..]
        else
          headers = nil
          data_rows = rows
        end

        # Extract data from rows
        parsed_rows = data_rows.map do |row|
          Row.new(extract_row_cells(row), headers:)
        end

        Tables::Base::Result.new(rows: parsed_rows, headers:)
      end

      private

      def extract_table_node(html_data)
        case html_data
        when String
          return nil if html_data.strip.empty?

          Nokogiri::HTML(html_data).at_css('table')
        when Nokogiri::XML::Element, Nokogiri::XML::NodeSet
          html_data.name == 'table' ? html_data : html_data.at_css('table')
        else
          Nokogiri::HTML(html_data.to_s).at_css('table')
        end
      end

      def extract_row_cells(row)
        row.css('th, td').map do |cell|
          # Get text content
          text = cell.text
          
          # Handle JSON content specially to preserve important whitespace
          if text.include?('{') && text.include?('}')
            # Process JSON content more carefully
            # 1. Remove newlines
            # 2. Preserve spaces between JSON delimiters
            # 3. Normalize other whitespace
            json_content = text.gsub(/\r?\n/, ' ')        # Replace newlines with spaces
                              .gsub(/(\{)\s*/, '\1 ')     # Ensure exactly one space after opening brace
                              .gsub(/\s*(\})/, ' \1')     # Ensure exactly one space before closing brace
                              .gsub(/\s+/, ' ')           # Collapse other consecutive whitespace
                              .gsub(/\A\s+|\s+\z/, '')    # Trim leading/trailing whitespace
                              .gsub(/\u00A0/, ' ')        # Replace &nbsp; with spaces
            json_content
          else
            # For regular content
            text.gsub(/\r?\n/, '')          # Remove all newlines completely
                .gsub(/\s+/, ' ')           # Collapse consecutive whitespace
                .gsub(/\A\s+|\s+\z/, '')    # Trim leading/trailing whitespace
                .gsub(/\u00A0/, ' ')        # Replace &nbsp; with spaces
          end
        end
      end

      def first_row
        @first_row ||= rows.first
      end

      def has_headers?
        @has_headers ||= first_row.css('th').any? || @headers_flag
      end

      def rows
        @rows ||= table.css('tr')
      end
    end
  end
end
