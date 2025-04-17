# frozen_string_literal: true

module Marktable
  class Row
    attr_reader :data, :headers

    def initialize(data = {}, headers: nil)
      @headers = headers
      
      if data.is_a?(Hash)
        @data = data.dup
      elsif data.is_a?(Array)
        @data = if headers && !headers.empty?
          # Convert array to hash using headers
          headers.each_with_index.each_with_object({}) do |(header, i), hash|
            hash[header] = i < data.length ? data[i] : ''
          end
        else
          # Keep as array when no headers
          data.dup
        end
      else
        @data = headers ? {} : []
      end
    end

    def [](key)
      if @data.is_a?(Hash)
        @data[key]
      elsif key.is_a?(Integer) && key < @data.length
        @data[key]
      else
        nil
      end
    end

    def []=(key, value)
      if @data.is_a?(Hash)
        @data[key] = value
      elsif key.is_a?(Integer)
        @data[key] = value
      end
    end

    def values
      @data.is_a?(Hash) ? @data.values : @data
    end

    def keys
      @data.is_a?(Hash) ? @data.keys : (0...@data.size).to_a
    end

    def to_h
      return @data if @data.is_a?(Hash)
      return {} if @data.empty? || @headers.nil? || @headers.empty?
      
      @headers.each_with_index.each_with_object({}) do |(header, i), hash|
        hash[header] = i < @data.length ? @data[i] : ''
      end
    end

    def to_a
      @data.is_a?(Array) ? @data : @data.values
    end

    def with_headers
      return self if @headers
      return self if !@data.is_a?(Array)
      
      # This is only applicable when converting from array-based to hash-based
      Row.new(@data, headers: @headers)
    end

    # Convert a row to markdown format with specified column widths
    def to_markdown(column_widths)
      vals = values
      formatted_values = vals.each_with_index.map do |val, i|
        val.to_s.ljust(column_widths[i] || val.to_s.length)
      end
      "| #{formatted_values.join(' | ')} |"
    end

    # Parse a markdown row string into an array of values
    def self.parse(row_string)
      row_string.strip.sub(/^\|/, '').sub(/\|$/, '').split('|').map(&:strip)
    end

    # Check if a row string represents a separator row
    def self.separator?(row_string)
      row_string.strip.gsub(/[\|\-\s]/, '').empty?
    end

    # Generate a separator row for markdown table with specified widths
    def self.separator_row(column_widths)
      adjusted_widths = column_widths.dup
      
      separators = column_widths.map do |width|
        '-' * [3, width].max
      end
      
      ["| #{separators.join(' | ')} |", adjusted_widths]
    end
  end
end
