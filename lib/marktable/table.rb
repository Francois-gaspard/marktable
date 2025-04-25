# frozen_string_literal: true

require_relative 'formatters/base'

module Marktable
  class Table
    include Enumerable

    attr_reader :headers

    def initialize(source, type: :markdown, headers: nil)
      parser = Tables::Base.for(type).new(source, headers)
      result = parser.parse
      @rows = result.rows
      @headers = result.headers
      # Validate headers if present
      validate_headers if @headers
      # Fix: Initialize @has_headers based on whether @headers is present
      @has_headers = !@headers.nil?
    end

    # Iteration support
    def each(&block)
      return enum_for(:each) unless block_given?

      @rows.each(&block)
    end

    # Returns the table as an Array of Hashes if headers are present
    # or Array of Arrays if no headers
    def to_a
      if @has_headers
        # Convert rows to hashes, which will automatically exclude values without headers
        @rows.map(&:to_hash)
      else
        # When no headers, return array of arrays with consistent length
        max_length = @rows.map { |row| row.values.length }.max || 0
        @rows.map do |row|
          values = row.values
          values + Array.new(max_length - values.length, '')
        end
      end
    end

    def to_html
      Formatters::Base.for(:html).format(@rows, @headers)
    end

    # Generate markdown representation
    def to_md
      Formatters::Base.for(:markdown).format(@rows, @headers)
    end
    alias generate to_md

    # Generate CSV representation
    def to_csv
      Formatters::Base.for(:csv).format(@rows, @headers)
    end

    # Support for accessing by index like table[0]
    def [](index)
      @rows[index]
    end

    # Returns the number of rows
    def size
      @rows.size
    end
    alias length size

    def empty?
      @rows.empty?
    end

    private

    def validate_headers
      duplicates = @headers.group_by { |h| h }.select { |_, v| v.size > 1 }.keys
      return unless duplicates.any?

      raise ArgumentError, "Duplicate headers are not allowed: #{duplicates.join(', ')}"
    end
  end
end
