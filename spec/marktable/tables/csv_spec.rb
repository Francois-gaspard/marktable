# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Marktable::Tables::CSV do
  before do
    @markdown = <<~MARKDOWN
      | Name  | Age | City     |
      | ----- | --- | -------- |
      | Alice | 30  | New York |
      | Bob   | 25  | London   |
      | Carol | 35  | Tokyo    |
    MARKDOWN

    @csv_string = <<~CSV
      Name,Age,City
      Alice,30,New York
      Bob,25,London
      Carol,35,Tokyo
    CSV
  end

  context 'with CSV string input' do
    it 'parses CSV without headers by default' do
      csv = described_class.new(@csv_string, false)
      result = csv.parse
      expect(result.headers).to be_nil
      expect(result.rows.size).to eq(4) # includes header row as data
    end
    
    it 'parses CSV with headers' do
      csv = described_class.new(@csv_string, true)
      result = csv.parse
      expect(result.headers).to eq(%w[Name Age City])
      expect(result.rows.size).to eq(3)
      expect(result.rows.first.values).to eq(['Alice', '30', 'New York'])
    end
  end

  context 'with CSV::Table input' do
    it 'parses CSV::Table with headers' do
      csv_table = ::CSV.parse(@csv_string, headers: true)
      csv = described_class.new(csv_table, true)
      result = csv.parse
      expect(result.headers).to eq(%w[Name Age City])
      expect(result.rows.size).to eq(3)
    end
  end

  context 'with invalid input' do
    it 'raises ArgumentError for invalid input type' do
      expect { described_class.new(123, true).parse }.to raise_error(ArgumentError, /Cannot parse CSV from/)
    end
  end
  
  context 'with empty inputs' do
    it 'handles empty CSV string' do
      csv = described_class.new('', false)
      result = csv.parse
      expect(result.headers).to be_nil
      expect(result.rows).to be_empty
    end
  end
end
