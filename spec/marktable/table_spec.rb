# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Marktable::Table do

  describe '#to_a' do
    it 'returns an empty array for empty input' do
      table = described_class.new('')
      expect(table.to_a).to eq([])
    end
    
    it 'returns an empty array for input with only whitespace' do
      table = described_class.new("  \n  \n  ")
      expect(table.to_a).to eq([])
    end
    
    it 'correctly parses a simple markdown table' do
      markdown = <<~MARKDOWN
        | Name | Age |
        | ---- | --- |
        | John | 30  |
        | Jane | 25  |
      MARKDOWN
      
      expected = [
        { "Name" => "John", "Age" => "30" },
        { "Name" => "Jane", "Age" => "25" }
      ]
      
      table = described_class.new(markdown)
      expect(table.to_a).to eq(expected)
    end
    
    it 'correctly parses a simple markdown table with headers: false' do
      markdown = <<~MARKDOWN
        | Name | Age |
        | ---- | --- |
        | John | 30  |
        | Jane | 25  |
      MARKDOWN
      
      expected = [
        ["Name", "Age"],
        ["John", "30"],
        ["Jane", "25"]
      ]
      
      table = described_class.new(markdown, headers: false)
      expect(table.to_a).to eq(expected)
    end
    
    it 'handles tables without surrounding pipes' do
      markdown = <<~MARKDOWN
        Name | Age
        ---- | ---
        John | 30
      MARKDOWN
      
      expected = [
        { "Name" => "John", "Age" => "30" }
      ]
      
      table = described_class.new(markdown)
      expect(table.to_a).to eq(expected)
    end
    
    it 'handles rows with fewer columns than headers' do
      markdown = <<~MARKDOWN
        | Name | Age | City |
        | ---- | --- | ---- |
        | John | 30  |      |
        | Jane |     |      |
      MARKDOWN
      
      expected = [
        { "Name" => "John", "Age" => "30", "City" => '' },
        { "Name" => "Jane", "Age" => '', "City" => '' }
      ]
      
      table = described_class.new(markdown)
      expect(table.to_a).to eq(expected)
    end
    
    it 'ignores additional cells in rows with more columns than headers' do
      markdown = <<~MARKDOWN
        | Name | Age |
        | ---- | --- |
        | John | 30  | New York |
      MARKDOWN
      
      expected = [
        { "Name" => "John", "Age" => "30" }
      ]
      
      table = described_class.new(markdown)
      expect(table.to_a).to eq(expected)
    end
    
    it 'handles tables with multiple separator rows' do
      markdown = <<~MARKDOWN
        | Name | Age |
        | ---- | --- |
        | John | 30  |
        | ---- | --- |
        | Jane | 25  |
      MARKDOWN
      
      expected = [
        { "Name" => "John", "Age" => "30" },
        { "Name" => "Jane", "Age" => "25" }
      ]
      
      table = described_class.new(markdown)
      expect(table.to_a).to eq(expected)
    end
  end

  describe '#generate' do
    it 'returns an empty string for empty input' do
      table = described_class.new('')
      expect(table.generate).to eq('')
    end
    
    it 'generates markdown table with properly spaced columns' do
      data = [
        { "Name" => "John", "Age" => "30", "City" => "New York" },
        { "Name" => "Jane", "Age" => "25", "City" => "Boston" }
      ]
      
      table = Marktable.table(data)
      result = table.generate
      
      expected = <<~MARKDOWN.chomp
        | Name | Age | City     |
        | ---- | --- | -------- |
        | John | 30  | New York |
        | Jane | 25  | Boston   |
      MARKDOWN
      
      expect(result).to eq(expected)
    end
    
    it 'handles data with varying cell lengths' do
      data = [
        { "Short" => "A", "Very Long Column" => "Short", "Col" => "Medium Data" },
        { "Short" => "Longer Value", "Very Long Column" => "X", "Col" => "Y" }
      ]
      
      table = Marktable.table(data)
      result = table.generate
      
      expected = <<~MARKDOWN.chomp
        | Short        | Very Long Column | Col         |
        | ------------ | ---------------- | ----------- |
        | A            | Short            | Medium Data |
        | Longer Value | X                | Y           |
      MARKDOWN
      
      expect(result).to eq(expected)
    end
    
    it 'generates proper markdown table from array data with headers: false' do
      data = [
        ["Name", "Age", "City"],
        ["John", "30", "New York"],
        ["Jane", "25", "Boston"]
      ]
      
      table = Marktable.table(data, headers: false)
      result = table.generate
      
      expected = <<~MARKDOWN.chomp
        | Name | Age | City     |
        | ---- | --- | -------- |
        | John | 30  | New York |
        | Jane | 25  | Boston   |
      MARKDOWN
      
      expect(result).to eq(expected)
    end
  end
end
