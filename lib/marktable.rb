# frozen_string_literal: true

require_relative 'marktable/version'
require_relative 'marktable/row'
require_relative 'marktable/tables/base'
require_relative 'marktable/table'

module Marktable
  def self.from_markdown(table, headers: nil)
    Table.new(table, type: :markdown, headers:)
  end

  def self.from_csv(table, headers: nil)
    Table.new(table, type: :csv, headers:)
  end

  def self.from_array(table, headers: nil)
    Table.new(table, type: :array, headers:)
  end

  def self.from_html(table)
    Table.new(table, type: :html)
  end
end
