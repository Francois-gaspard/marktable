# frozen_string_literal: true

require_relative 'markdown'
require_relative 'array'
require_relative 'csv'
require_relative 'html'

module Marktable
  module Tables
    class Base
      Result = Struct.new(:rows, :headers, keyword_init: true)

      def self.for(type)
        case type.to_sym
        when :markdown
          Markdown
        when :array
          Array
        when :csv
          CSV
        when :html
          HTML
        else
          raise ArgumentError, "Unknown table type: #{type}"
        end
      end

      def self.blank
        Result.new(rows: [], headers: nil)
      end
    end
  end
end
