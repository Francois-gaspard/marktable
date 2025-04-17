# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Marktable do
  let(:markdown_table) do
    <<~MARKDOWN
      | Name | Age | City     |
      | ---- | --- | -------- |
      | John | 30  | New York |
      | Jane | 25  | Boston   |
    MARKDOWN
  end

  describe '.parse' do
    it 'parses a markdown table into an array of hashes' do
      result = described_class.parse(markdown_table)
      expect(result).to eq([
        { "Name" => "John", "Age" => "30", "City" => "New York" },
        { "Name" => "Jane", "Age" => "25", "City" => "Boston" }
      ])
    end
    
    it 'parses a markdown table into an array of arrays with headers: false' do
      result = described_class.parse(markdown_table, headers: false)
      expect(result).to eq([
        ["Name", "Age", "City"],
        ["John", "30", "New York"],
        ["Jane", "25", "Boston"]
      ])
    end
  end
  
  describe '.parse_line' do
    it 'parses a markdown row into an array of values' do
      row = "| John | 30  | New York |"
      result = described_class.parse_line(row)
      expect(result).to eq(["John", "30", "New York"])
    end
    
    it 'handles rows without surrounding pipes' do
      row = "John | 30 | New York"
      result = described_class.parse_line(row)
      expect(result).to eq(["John", "30", "New York"])
    end
  end
  
  describe '.foreach' do
    it 'iterates through each row of the table' do
      rows = []
      described_class.foreach(markdown_table) do |row|
        rows << row
      end
      
      expect(rows).to eq([
        { "Name" => "John", "Age" => "30", "City" => "New York" },
        { "Name" => "Jane", "Age" => "25", "City" => "Boston" }
      ])
    end
    
    it 'returns an enumerator when no block is given' do
      enum = described_class.foreach(markdown_table)
      expect(enum).to be_a(Enumerator)
      
      rows = enum.to_a
      expect(rows).to eq([
        { "Name" => "John", "Age" => "30", "City" => "New York" },
        { "Name" => "Jane", "Age" => "25", "City" => "Boston" }
      ])
    end
  end
  
  describe '.generate' do
    it 'generates a markdown table from data' do
      result = described_class.generate do |table|
        table << { "Name" => "John", "Age" => "30", "City" => "New York" }
        table << { "Name" => "Jane", "Age" => "25", "City" => "Boston" }
      end
      
      expected = <<~MARKDOWN.chomp
        | Name | Age | City     |
        | ---- | --- | -------- |
        | John | 30  | New York |
        | Jane | 25  | Boston   |
      MARKDOWN
      
      expect(result).to match_markdown(expected)
    end
    
    it 'generates a table with provided headers' do
      headers = ["Name", "Age", "City"]
      result = described_class.generate(headers: headers) do |table|
        table << { "Name" => "John", "Age" => "30", "City" => "New York" }
        table << { "Name" => "Jane", "Age" => "25", "City" => "Boston" }
      end
      
      expect(result).to match_markdown(markdown_table)
    end
  end

  describe '.filter' do
    it 'filters rows matching a pattern' do
      result = described_class.filter(markdown_table, /John/)
      
      expected = <<~MARKDOWN.chomp
        | Name | Age | City     |
        | ---- | --- | -------- |
        | John | 30  | New York |
      MARKDOWN
      
      expect(result).to match_markdown(expected)
    end
  end

  describe '.map' do
    it 'maps rows to new values' do
      result = described_class.map(markdown_table) do |row|
        row["Age"] = row["Age"].to_i + 1
        row
      end
      
      expected = <<~MARKDOWN.chomp
        | Name | Age | City     |
        | ---- | --- | -------- |
        | John | 31  | New York |
        | Jane | 26  | Boston   |
      MARKDOWN
      
      expect(result).to match_markdown(expected)
    end
  end
end
