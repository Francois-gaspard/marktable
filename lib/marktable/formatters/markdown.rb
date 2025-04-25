# frozen_string_literal: true

module Marktable
  module Formatters
    class Markdown
      def self.format(rows, headers = nil)
        return '' if rows.empty? && headers.nil?

        # Calculate column widths
        widths = calculate_column_widths(rows, headers)

        lines = []

        # Add header row if we have headers
        if headers
          lines << Row.new(headers).to_markdown(widths)
          lines << separator_row(widths)
        end

        # Add data rows
        rows.each do |row|
          lines << row.to_markdown(widths)
        end

        lines.join("\n")
      end

      def self.calculate_column_widths(rows, headers)
        # Determine the maximum number of columns to consider
        max_cols = headers ? headers.size : 0

        if headers.nil?
          # Without headers, find the maximum number of values across all rows
          rows.each do |row|
            max_cols = [max_cols, row.values.size].max
          end
        end

        # Initialize widths array with zeros
        widths = Array.new(max_cols, 0)

        # Process headers if available
        headers&.each_with_index do |header, i|
          width = header.to_s.length
          widths[i] = width if width > widths[i]
        end

        # Process row values, but only up to the max_cols
        rows.each do |row|
          values = row.values.take(max_cols)
          values.each_with_index do |value, i|
            width = value.to_s.length
            widths[i] = width if width > widths[i]
          end
        end

        widths
      end

      def self.separator_row(widths)
        separator_parts = widths.map { |width| '-' * width }
        "| #{separator_parts.join(' | ')} |"
      end
    end
  end
end
