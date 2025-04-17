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
    markdown_row.strip.sub(/^\|/, '').sub(/\|$/, '').split('|').map(&:strip)
  end

  # Iterate through each row of a markdown table
  def self.foreach(markdown_table, headers: true)
    table = Table.new(markdown_table, headers: headers)
    return table.enum_for(:each) unless block_given?
    
    table.each do |row|
      yield row
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
        # Create a Table object to leverage the proper formatting
        table = table(table_data, headers: headers.nil? ? true : false)
        
        # Set headers if provided
        if headers
          table.instance_variable_set(:@header_row, headers.each_with_object({}) { |k, h| h[k] = k })
          table.instance_variable_set(:@headers, true)
        end
        
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
                generate do |csv|
                  table_or_data.each { |row| csv << row }
                end
              end
    
    File.write(path, content)
  end

  # Convert an array to a Marktable::Table
  def self.table(array, headers: true)
    table = Table.new([], headers: headers)
    
    if headers && array.first.is_a?(Hash)
      header_keys = array.first.keys
      table.instance_variable_set(:@header_row, header_keys.each_with_object({}) { |k, h| h[k] = k })
      table.instance_variable_set(:@rows, array.map { |row_data| Row.new(row_data, headers: header_keys) })
    else
      table.instance_variable_set(:@rows, array.map { |row_data| Row.new(row_data, headers: nil) })
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

  # Map over rows
  def self.map(markdown_table, headers: true)
    table = Table.new(markdown_table, headers: headers)
    mapped_rows = []
    
    table.each do |row|
      mapped_rows << yield(row)
    end
    
    table(mapped_rows, headers: headers)
  end
end
