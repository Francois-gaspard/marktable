# frozen_string_literal: true

module Marktable
  class Row
    attr_reader :values, :headers

    def initialize(data, headers: nil)
      @headers = headers
      @values = extract_values(data)
    end

    # Format the row as a markdown table row
    def to_markdown(column_widths)
      vals = @values

      # Limit values to either headers count or column_widths size, whichever is appropriate
      max_cols = @headers ? @headers.size : column_widths.size

      formatted_values = column_widths.take(max_cols).map.with_index do |width, i|
        if i < vals.size
          vals[i].to_s.ljust(width)
        else
          ''.ljust(width)
        end
      end

      "| #{formatted_values.join(' | ')} |"
    end

    # Access a value by index or header
    def [](key)
      if key.is_a?(Integer)
        @values[key]
      elsif @headers
        idx = @headers.index(key)
        idx ? @values[idx] : nil
      end
    end

    # Set a value by index or header
    def []=(key, value)
      if key.is_a?(Integer)
        @values[key] = value if key >= 0 && key < @values.size
      elsif @headers
        idx = @headers.index(key)
        @values[idx] = value if idx && idx < @values.size
      end
    end

    # Check if this row uses headers
    def headers?
      !@headers.nil?
    end

    # Convert row data to a hash using headers as keys
    def to_hash
      return {} unless @headers

      result = {}
      @values.each_with_index do |value, i|
        # Only include values that have a corresponding header
        if i < @headers.size
          header = @headers[i]
          result[header] = value if header
        end
      end
      result
    end

    # Parse a markdown row string into an array of values
    def self.parse(row_string)
      # Skip if nil or empty
      return [] if row_string.nil? || row_string.strip.empty?

      # Remove leading/trailing pipes and split by pipe
      cells = row_string.strip.sub(/^\|/, '').sub(/\|$/, '').split('|')

      # Trim whitespace from each cell
      cells.map(&:strip)
    end

    # Check if a row is a separator row
    def self.separator?(row_string)
      # Skip if nil or empty
      return false if row_string.nil? || row_string.strip.empty?

      # Remove pipes and strip whitespace
      content = row_string.gsub('|', '').strip

      # Check if it contains only dashes and colons (separator characters)
      content.match?(/^[\s:,-]+$/) && content.include?('-')
    end

    private

    def extract_values(data)
      case data
      when Hash
        if @headers
          @headers.map { |h| data[h] || '' }
        else
          data.values
        end
      else
        # Array or other enumerable
        Array(data)
      end
    end
  end
end
