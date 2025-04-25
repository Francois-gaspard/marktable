# frozen_string_literal: true

require 'nokogiri'

module Marktable
  module Formatters
    class HTML
      def self.format(rows, headers = nil)
        return '' if rows.empty? && headers.nil?

        builder = Nokogiri::HTML::Builder.new do |doc|
          doc.table do
            if headers
              doc.thead do
                doc.tr do
                  headers.each do |header|
                    doc.th { doc.text header }
                  end
                end
              end
            end

            doc.tbody do
              rows.each do |row|
                doc.tr do
                  row.values.each do |cell|
                    doc.td do
                      cell_text = cell.to_s
                      if cell_text.include?('\n')
                        cell_text.split('\n').each_with_index do |line, index|
                          doc.br if index.positive?
                          doc.text line
                        end
                      else
                        doc.text cell_text
                      end
                    end
                  end
                end
              end
            end
          end
        end

        # Extract just the table element to avoid including DOCTYPE
        builder.doc.at_css('table').to_html
      end
    end
  end
end
