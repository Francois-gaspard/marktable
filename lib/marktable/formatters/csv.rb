# frozen_string_literal: true

require 'csv'

module Marktable
  module Formatters
    class CSV
      def self.format(rows, headers = nil)
        return '' if rows.empty? && headers.nil?

        ::CSV.generate do |csv|
          csv << headers if headers
          rows.each do |row|
            csv << format_row(row)
          end
        end
      end

      def self.format_row(row)
        row.values.map { |val| val unless val.to_s.empty? }
      end
    end
  end
end
