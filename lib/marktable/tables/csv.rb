# frozen_string_literal: true

require 'csv'
require_relative 'base'

module Marktable
  module Tables
    class CSV
      def initialize(csv_data, headers)
        @csv_data = csv_data
        @headers_flag = headers
      end

      def parse
        csv_table = parse_csv

        if with_headers?
          parse_with_headers(csv_table)
        else
          parse_without_headers(csv_table)
        end
      end

      private

      def parse_csv
        case @csv_data
        when ::CSV::Table
          @csv_data
        when String
          ::CSV.parse(@csv_data, headers: @headers_flag)
        else
          raise ArgumentError, "Cannot parse CSV from #{@csv_data.class}"
        end
      end

      def with_headers?
        @headers_flag || (@csv_data.is_a?(::CSV::Table) && @csv_data.headers.any?)
      end

      def parse_with_headers(csv_table)
        headers = csv_table.headers
        rows = []

        csv_table.each do |csv_row|
          # Convert CSV::Row to hash then to our Row
          row_data = csv_row.to_h
          rows << Row.new(row_data, headers: headers)
        end

        Tables::Base::Result.new(rows:, headers:)
      end

      def parse_without_headers(csv_table)
        rows = []

        if csv_table.is_a?(::CSV::Table)
          csv_table.each do |csv_row|
            rows << Row.new(csv_row.fields)
          end
        else
          csv_table.each do |fields|
            rows << Row.new(fields)
          end
        end

        Tables::Base::Result.new(rows:, headers: nil)
      end
    end
  end
end
