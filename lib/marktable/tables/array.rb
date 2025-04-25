# frozen_string_literal: true

require_relative 'base'

module Marktable
  module Tables
    class Array
      def initialize(array, headers)
        @array = array
        @headers_flag = headers
      end

      def parse
        return Tables::Base.blank if @array.empty?

        # Determine if this is an array of hashes or array of arrays
        if @array.first.is_a?(Hash)
          parse_array_of_hashes
        else
          parse_array_of_arrays
        end
      end

      private

      def parse_array_of_hashes
        # Extract all unique keys from all hashes to handle mismatched keys
        headers = @array.flat_map(&:keys).uniq

        # Create Row objects for each hash
        rows = @array.map do |hash|
          Row.new(hash, headers: headers)
        end

        Tables::Base::Result.new(rows:, headers:)
      end

      def parse_array_of_arrays
        # Arrays of arrays can have an optional header row
        if @headers_flag
          headers = @array.first
          data_rows = @array[1..]
        else
          headers = nil
          data_rows = @array
        end

        # Create Row objects for each array
        rows = data_rows.map do |values|
          Row.new(values, headers: headers)
        end

        Tables::Base::Result.new(rows:, headers:)
      end
    end
  end
end
