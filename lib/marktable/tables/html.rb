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

      def rows
        @rows ||= table.css('tr')
      end

      def first_row
        rows.first
      end

      def has_headers?
        return false if @headers_flag == false
        return true if @headers_flag == true

        # Auto-detect headers if not explicitly specified
        first_row&.css('th').any?
      end

      def extract_row_cells(row)
        row.css('th, td').map { |cell| cell.text.tr("\n", ' ').strip }
      end
    end
  end
end
