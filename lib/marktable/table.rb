# frozen_string_literal: true

module Marktable
  class Table
    include Enumerable
    
    attr_reader :headers

    def initialize(markdown_table = '', headers: true)
      @headers = headers
      @rows = []
      @header_row = nil
      parse_content(markdown_table) unless markdown_table.empty?
    end

    def each
      if block_given?
        @rows.each { |row| yield(row) }
      else
        @rows.each
      end
    end

    def to_a
      @rows.map { |row| row.data }
    end

    def to_s
      generate
    end

    def generate
      return "" if @rows.empty?

      # Extract header keys or use first row data for header
      keys = header_keys
      
      # Calculate column widths considering both headers and all row values
      all_values = [keys] + @rows.map { |row| row.values }
      column_widths = calculate_column_widths(all_values)
      
      # Build the markdown table
      build_markdown_table(keys, column_widths)
    end

    private

    def header_keys
      if @headers && @header_row
        @header_row.keys
      elsif @rows.first&.data.is_a?(Hash)
        @rows.first.data.keys
      else
        @rows.first&.values || []
      end
    end

    def build_markdown_table(keys, column_widths)
      result = []
      
      # Add header row
      result << row_to_markdown(keys, column_widths)
      
      # Add separator row
      separator, _ = Row.separator_row(column_widths)
      result << separator
      
      # Add data rows
      rows_to_render.each do |row|
        result << row.to_markdown(column_widths)
      end
      
      result.join("\n")
    end

    def rows_to_render
      if !@headers && !@rows.first&.data.is_a?(Hash) && @rows.size > 1
        @rows[1..-1]
      else
        @rows
      end
    end

    def parse_content(markdown_table)
      # Split content into rows
      rows = markdown_table.split("\n").map(&:strip).reject(&:empty?)
      return if rows.empty?

      if @headers
        parse_with_headers(rows)
      else
        parse_without_headers(rows)
      end
    end

    def parse_with_headers(rows)
      # Extract headers from first row
      header_values = Row.parse(rows.first)
      @header_row = header_values.each_with_object({}) { |val, hash| hash[val] = val }

      # Process each data row
      rows.each_with_index do |row, index|
        # Skip header row and separator rows
        next if index == 0 || Row.separator?(row)

        # Parse the row into values
        values = Row.parse(row)

        # Create a hash mapping headers to values
        row_hash = {}
        header_values.each_with_index do |header, i|
          row_hash[header] = i < values.length ? values[i] : ''
        end

        @rows << Row.new(row_hash, headers: header_values)
      end
    end

    def parse_without_headers(rows)
      # When headers: false, store array of arrays
      rows.each do |row|
        # Skip separator rows
        next if Row.separator?(row)

        # Parse the row into values
        values = Row.parse(row)
        @rows << Row.new(values, headers: nil)
      end
    end

    # Calculate the maximum width of each column
    def calculate_column_widths(arrays_of_values)
      max_column_count = arrays_of_values.map { |row| row.size }.max || 0
      column_widths = Array.new(max_column_count, 0)
      
      arrays_of_values.each do |row|
        row.each_with_index do |cell, i|
          cell_width = cell.to_s.length
          column_widths[i] = [column_widths[i], cell_width].max
        end
      end
      
      column_widths
    end

    # Generate markdown row from array of values with proper spacing
    def row_to_markdown(values, column_widths)
      formatted_values = values.each_with_index.map do |val, i|
        val.to_s.ljust(column_widths[i])
      end
      "| #{formatted_values.join(' | ')} |"
    end
  end
end
