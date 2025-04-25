# frozen_string_literal: true

require_relative 'base'

module Marktable
  module Tables
    class Markdown
      # @param [table] [String] The markdown table string.
      # @param [headers] [boolean] Whether the table has headers or not.
      #  If nil, it will be inferred from the table content.
      def initialize(table, headers)
        @headers_flag = headers
        @markdown_rows = extract_rows(table)
      end

      def parse
        if with_headers?
          parse_with_headers
        else
          parse_without_headers
        end
      end

      private

      def extract_rows(table)
        return [] if table.nil? || table.empty?

        table.split("\n").map(&:strip).reject(&:empty?)
      end

      def infer_headers
        # At least 2 rows with the second being a separator
        @markdown_rows.size >= 2 && Row.separator?(@markdown_rows[1])
      end

      def extract_header_values
        Row.parse(@markdown_rows.first)
      end

      def with_headers?
        # If headers flag is explicitly provided, use it
        # Otherwise infer from the table structure
        return @headers_flag unless @headers_flag.nil?

        infer_headers
      end

      def parse_with_headers
        return [[], []] if @markdown_rows.empty?

        header_values = extract_header_values
        rows = []

        @markdown_rows.each_with_index do |row_string, index|
          # Skip header row and separator row
          next if index.zero? || Row.separator?(row_string)

          values = Row.parse(row_string)
          rows << Row.new(values, headers: header_values)
        end

        Tables::Base::Result.new(rows:, headers: header_values)
      end

      def parse_without_headers
        rows = []

        @markdown_rows.each do |row_string|
          # Skip separator rows
          next if Row.separator?(row_string)

          # Parse the row into values
          values = Row.parse(row_string)
          rows << Row.new(values)
        end

        Tables::Base::Result.new(rows:, headers: nil)
      end
    end
  end
end
