# frozen_string_literal: true

require_relative 'marktable/row'
require_relative 'marktable/table'

module Marktable
  # Parse a markdown table string into an array of rows
  def self.parse(markdown_table, headers: true)
    Table.new(markdown_table, headers: headers).to_a
  end

  # Parse a single markdown row into an array of cell values
  def self.parse_line(markdown_row)
    Row.parse(markdown_row)
  end

  # Iterate through each row of a markdown table
  def self.foreach(markdown_table, headers: true)
    table = Table.new(markdown_table, headers: headers)
    return Enumerator.new do |yielder|
      table.each do |row|
        yielder << row.data
      end
    end unless block_given?
    
    table.each do |row|
      yield row.data
    end
  end

  # Generate a markdown table from provided data
  def self.generate(headers: nil)
    result = []
    markdown_table = ''
    
    if block_given?
      table_data = []
      yield table_data
      
      unless table_data.empty?
        # Ensure all data is stringified
        string_data = table_data.map do |row|
          if row.is_a?(Hash)
            row.transform_values(&:to_s)
          else
            row.map(&:to_s)
          end
        end
        
        # Create a Table object
        table = table(string_data, headers: headers.nil? ? true : headers)
        
        markdown_table = table.generate
      end
    end
    
    markdown_table
  end

  # Read a markdown table from a file
  def self.read(path, headers: true)
    content = File.read(path)
    Table.new(content, headers: headers)
  end

  # Write a markdown table to a file
  def self.write(path, table_or_data)
    content = if table_or_data.is_a?(Table)
                table_or_data.to_s
              else
                table(table_or_data).to_s
              end
    
    File.write(path, content)
  end

  # Convert an array to a Marktable::Table
  def self.table(array, headers: true)
    table = Table.new([], headers: headers)
    
    # Ensure all data values are strings
    string_array = array.map do |row|
      # Handle Row instances by extracting their data
      if row.is_a?(Row)
        row.data
      elsif row.is_a?(Hash)
        row.transform_values(&:to_s)
      else
        row.map(&:to_s)
      end
    end
    
    if headers && string_array.first.is_a?(Hash)
      header_keys = string_array.first.keys
      table.instance_variable_set(:@header_row, header_keys.each_with_object({}) { |k, h| h[k] = k })
      table.instance_variable_set(:@rows, string_array.map { |row_data| Row.new(row_data, headers: header_keys) })
    else
      table.instance_variable_set(:@rows, string_array.map { |row_data| Row.new(row_data, headers: nil) })
    end
    
    table
  end

  # Filter rows matching a pattern
  def self.filter(markdown_table, pattern, headers: true)
    table = Table.new(markdown_table, headers: headers)
    filtered_rows = table.to_a.select do |row|
      if row.is_a?(Hash)
        row.values.any? { |v| v.to_s.match?(pattern) }
      else
        row.any? { |v| v.to_s.match?(pattern) }
      end
    end
    
    table(filtered_rows, headers: headers)
  end

  # Map over rows (all values will be converted to strings)
  def self.map(markdown_table, headers: true)
    table = Table.new(markdown_table, headers: headers)
    mapped_rows = []
    
    table.each do |row|
      result = yield(row)
      # Ensure result is string-compatible
      if result.is_a?(Hash)
        result = result.transform_values(&:to_s)
      elsif result.is_a?(Array)
        result = result.map(&:to_s)
      end
      mapped_rows << result
    end
    
    table(mapped_rows, headers: headers)
  end
end
