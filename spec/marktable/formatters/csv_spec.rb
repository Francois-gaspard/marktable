# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Marktable::Formatters::CSV do
  context 'from a Marktable with headers' do
    before do
      markdown = <<~MARKDOWN
        | Name  | Age | City     |
        | ----- | --- | -------- |
        | Alice | 30  | New York |
        | Bob   | 25  | London   |
        | Carol | 35  | Tokyo    |
      MARKDOWN

      @table = Marktable.from_markdown(markdown)
    end

    it 'returns a CSV string' do
      expected = <<~CSV
        Name,Age,City
        Alice,30,New York
        Bob,25,London
        Carol,35,Tokyo
      CSV

      expect(@table.to_csv).to eq(expected)
    end
  end

  context 'from a Marktable without headers' do
    before do
      markdown = <<~MARKDOWN
        | 30  | New York |
        | 25  | London   |
        | 35  | Tokyo    |
      MARKDOWN

      @table = Marktable.from_markdown(markdown, headers: false)
    end

    it 'returns a CSV string' do
      expected = <<~CSV
        30,New York
        25,London
        35,Tokyo
      CSV

      expect(@table.to_csv).to eq(expected)
    end
  end

  context 'from a Marktable with empty cells' do
    before do
      markdown = <<~MARKDOWN
        | Name  | Age | City     |
        | ----- | --- | -------- |
        | Alice |     | New York |
        | Bob   | 25  |          |
        | Carol | 35  | Tokyo    |
      MARKDOWN

      @table = Marktable.from_markdown(markdown)
    end

    it 'returns a CSV string with empty cells' do
      expected = <<~CSV
        Name,Age,City
        Alice,,New York
        Bob,25,
        Carol,35,Tokyo
      CSV

      expect(@table.to_csv).to eq(expected)
    end
  end

  context 'with special characters that need escaping' do
    before do
      markdown = <<~MARKDOWN
        | Name      | Description                |
        | --------- | -------------------------- |
        | Product 1 | Contains "quoted" text     |
        | Product 2 | Has commas, in description |
        | Product 3 | Line 1\\nLine 2            |
      MARKDOWN

      @table = Marktable.from_markdown(markdown)
    end

    it 'correctly escapes special characters' do
      expected = <<~CSV
        Name,Description
        Product 1,"Contains ""quoted"" text"
        Product 2,"Has commas, in description"
        Product 3,Line 1\\nLine 2
      CSV

      expect(@table.to_csv).to eq(expected)
    end
  end

  context 'with a large table' do
    before do
      # Create a large table with 100 rows
      rows = 100.times.map { |i| "| Row #{i} | Value #{i} |" }
      markdown = "| Column 1 | Column 2 |\n| -------- | -------- |\n#{rows.join("\n")}"

      @table = Marktable.from_markdown(markdown)
    end

    it 'handles large tables efficiently' do
      csv = @table.to_csv
      expect(csv.lines.count).to eq(101) # 100 rows + header
      expect(csv.lines.first).to eq("Column 1,Column 2\n")
      expect(csv.lines.last).to eq("Row 99,Value 99\n")
    end
  end

  context 'with multiline content in cells' do
    before do
      markdown = <<~MARKDOWN
        | Name        | Bio                    |
        | ----------- | ---------------------- |
        | John Smith  | Software Engineer\\nSpecializes in Ruby |
        | Jane Doe    | Product Manager\\nMBA Graduate\\nTech Enthusiast |
      MARKDOWN

      @table = Marktable.from_markdown(markdown)
    end

    it 'properly formats multiline cell content' do
      expected = <<~CSV
        Name,Bio
        John Smith,Software Engineer\\nSpecializes in Ruby
        Jane Doe,Product Manager\\nMBA Graduate\\nTech Enthusiast
      CSV

      expect(@table.to_csv).to eq(expected)
    end
  end
end
