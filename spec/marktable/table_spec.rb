# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Marktable::Table do
  before do
    @markdown = <<~MARKDOWN
      | Name  | Age | City     |
      | ----- | --- | -------- |
      | Alice | 30  | New York |
      | Bob   | 25  | London   |
      | Carol | 35  | Tokyo    |
    MARKDOWN

    @markdown_without_header = <<~MARKDOWN
      | Name  | Age | City     |
      | Alice | 30  | New York |
      | Bob   | 25  | London   |
      | Carol | 35  | Tokyo    |
    MARKDOWN
  end

  context 'with markdown input' do
    it 'creates a table and preserves headers' do
      table = described_class.new(@markdown, type: :markdown)
      expect(table.headers).to eq(%w[Name Age City])
      expected = [
        { 'Name' => 'Alice', 'Age' => '30', 'City' => 'New York' },
        { 'Name' => 'Bob', 'Age' => '25', 'City' => 'London' },
        { 'Name' => 'Carol', 'Age' => '35', 'City' => 'Tokyo' }
      ]
      expect(table.to_a).to eq(expected)
      expect(table.to_md).to match_markdown(@markdown)
    end

    it 'can handle escaped characters' do
      markdown_with_escapes = <<~MARKDOWN
        | Name      | Description                |
        | --------- | -------------------------- |
        | Product 1 | "Contains ""quoted"" text" |
        | Product 2 | Has commas, in description |
        | Product 3 | Line 1\\nLine 2            |
      MARKDOWN

      table = described_class.new(markdown_with_escapes, type: :markdown)
      expect(table.headers).to eq(%w[Name Description])
      expected = [
        { 'Name' => 'Product 1', 'Description' => '"Contains ""quoted"" text"' },
        { 'Name' => 'Product 2', 'Description' => 'Has commas, in description' },
        { 'Name' => 'Product 3', 'Description' => 'Line 1\\nLine 2' }
      ]
      expect(table.to_a).to eq(expected)
      expect(table.to_md).to match_markdown(markdown_with_escapes)
    end
  end

  context 'with array of array input' do
    before do
      @array_of_arrays = [
        ['Name', 'Age', 'City'],
        ['Alice', '30', 'New York'],
        ['Bob', '25', 'London'],
        ['Carol', '35', 'Tokyo']
      ]
    end

    it 'parses to a matching table' do
      table = described_class.new(@array_of_arrays, type: :array, headers: false)
      expect(table.headers).to be_nil
      expect(table.to_md).to match_markdown(@markdown_without_header)
    end

    it 'detects the lack of headers' do
      table = described_class.new(@array_of_arrays, type: :array)
      expect(table.headers).to be_nil
      expect(table.to_md).to match_markdown(@markdown_without_header)
    end

    context 'with repeating headers' do
      it 'raises an exception for duplicate headers' do
        repeating_headers = [
          ['Name', 'Age', 'City', 'Name', 'City'],
          ['Alice', '30', 'New York', 'Alice', 'NY']
        ]

        expect do
          described_class.new(repeating_headers, type: :array, headers: true)
        end.to raise_error(ArgumentError, /Duplicate headers are not allowed/)
      end
    end

    context 'with mismatched array rows' do
      before do
        @mismatched_rows = [
          ['Name', 'Age', 'City'],
          ['Alice', '30'],
          ['Bob', '25', 'London', 'Extra', 'Data'],
          ['', '23']
        ]
      end

      it 'handles rows with different lengths' do
        table = described_class.new(@mismatched_rows, type: :array, headers: true)
        expect(table.headers).to eq(%w[Name Age City])
        expected = <<~MARKDOWN
          | Name  | Age | City   |
          | ----- | --- | ------ |
          | Alice | 30  |        |
          | Bob   | 25  | London |
          |       | 23  |        |
        MARKDOWN

        expect(table.to_md).to match_markdown(expected)
        expected = [
          { 'Age' => '30', 'Name' => 'Alice' },
          { 'Age' => '25', 'City' => 'London', 'Name' => 'Bob' },
          { 'Age' => '23', 'Name' => '' }
        ]
        expect(table.to_a).to eq(expected)
      end

      it 'handles rows with different lengths and no headers' do
        table = described_class.new(@mismatched_rows, type: :array, headers: false)
        expect(table.headers).to be_nil
        expected = <<~MARKDOWN
          | Name  | Age | City   |       |      |
          | Alice | 30  |        |       |      |
          | Bob   | 25  | London | Extra | Data |
          |       | 23  |        |       |      |
        MARKDOWN

        expect(table.to_md).to match_markdown(expected)
        expected = [
          ['Name', 'Age', 'City', '', ''],
          ['Alice', '30', '', '', ''],
          ['Bob', '25', 'London', 'Extra', 'Data'],
          ['', '23', '', '', '']
        ]
        expect(table.to_a).to eq(expected)
      end
    end
  end

  context 'with array of hashes input' do
    before do
      @array_of_hashes = [
        { 'Name' => 'Alice', 'Age' => '30', 'City' => 'New York' },
        { 'Name' => 'Bob', 'Age' => '25', 'City' => 'London' },
        { 'Name' => 'Carol', 'Age' => '35', 'City' => 'Tokyo' }
      ]
    end

    it 'parses to a matching table' do
      table = described_class.new(@array_of_hashes, type: :array)
      expect(table.headers).to eq(%w[Name Age City])
      expect(table.to_md).to match_markdown(@markdown)
    end

    context 'with mismatched hash keys' do
      before do
        @mismatched_hashes = [
          { 'Name' => 'Alice', 'Age' => '30', 'City' => 'New York' },
          { 'Name' => 'Bob', 'Country' => 'UK', 'Age' => '25' },
          { 'Name' => 'Carol', 'Age' => '35', 'City' => 'Tokyo', 'Status' => 'Active' }
        ]
      end

      it 'creates a table with union of all keys as headers' do
        table = described_class.new(@mismatched_hashes, type: :array)
        expect(table.headers.sort).to eq(%w[Age City Country Name Status].sort)
        expected = <<~MARKDOWN

          | Name  | Age | City     | Country | Status |
          | ----- | --- | ------   | ------- | ------ |
          | Alice | 30  | New York |         |        |
          | Bob   | 25  |          | UK      |        |
          | Carol | 35  | Tokyo    |         | Active |
        MARKDOWN
        expect(table.to_md).to match_markdown(expected)
      end
    end
  end

  context 'with HTML string input' do
    before do
      @html = <<~HTML
        <table>
          <tr>
            <th>Name</th>
            <th>Age</th>
            <th>City</th>
          </tr>
          <tr>
            <td>Alice</td>
            <td>30</td>
            <td>New York</td>
          </tr>
          <tr>
            <td>Bob</td>
            <td>25</td>
            <td>London</td>
          </tr>
          <tr>
            <td>Carol</td>
            <td>35</td>
            <td>Tokyo</td>
          </tr>
        </table>
      HTML
    end

    it 'parses to a matching table' do
      table = described_class.new(@html, type: :html)
      expect(table.headers).to eq(%w[Name Age City])
      expect(table.to_md).to match_markdown(@markdown)
    end

    it 'handles HTML with no headers' do
      html_without_headers = <<~HTML
        <table>
          <tr>
            <td>Name</td>
            <td>Age</td>
            <td>City</td>
          </tr>
          <tr>
            <td>Alice</td>
            <td>30</td>
            <td>New York</td>
          </tr>
          <tr>
            <td>Bob</td>
            <td>25</td>
            <td>London</td>
          </tr>
          <tr>
            <td>Carol</td>
            <td>35</td>
            <td>Tokyo</td>
          </tr>
        </table>
      HTML
      table = described_class.new(html_without_headers, type: :html)
      expect(table.headers).to be_nil
      expect(table.to_md).to match_markdown(@markdown_without_header)
    end

    it 'handles HTML with no rows' do
      empty_html = <<~HTML
        <table>
          <tr>
            <th>Name</th>
            <th>Age</th>
            <th>City</th>
          </tr>
        </table>
      HTML
      table = described_class.new(empty_html, type: :html)
      expect(table.headers).to eq(%w[Name Age City])
      expected = <<~MARKDOWN

        | Name | Age | City |
        | ---- | --- | ---- |
      MARKDOWN
      expect(table.to_md).to match_markdown(expected)
    end

    it 'raises an exception with html with repeating headers' do
      repeating_headers_html = <<~HTML
        <table>
          <tr>
            <th>Name</th>
            <th>Age</th>
            <th>City</th>
            <th>Name</th>
          </tr>
          <tr>
            <td>Alice</td>
            <td>30</td>
            <td>New York</td>
            <td>Alice</td>
          </tr>
        </table>
      HTML

      expect do
        described_class.new(repeating_headers_html, type: :html)
      end.to raise_error(ArgumentError, /Duplicate headers are not allowed/)
    end

    it 'handles HTML with repeating values in the first row' do
      repeating_values_html = <<~HTML
        <table>
          <tr>
            <td>Name</td>
            <td>Age</td>
            <td>City</td>
            <td>Name</td>
          </tr>
          <tr>
            <td>Alice</td>
            <td>30</td>
            <td>New York</td>
            <td>Alice</td>
          </tr>
        </table>
      HTML

      table = described_class.new(repeating_values_html, type: :html)
      expect(table.headers).to eq(nil)
      expected = <<~MARKDOWN

        | Name  | Age | City     | Name  |
        | Alice | 30  | New York | Alice |
      MARKDOWN
      expect(table.to_md).to match_markdown(expected)
    end
  end

  context 'with Nokogiri::Node::Simple input' do
    before do
      @html = <<~HTML
        <table>
          <tr>
            <th>Name</th>
            <th>Age</th>
            <th>City</th>
          </tr>
          <tr>
            <td>Alice</td>
            <td>30</td>
            <td>New York</td>
          </tr>
          <tr>
            <td>Bob</td>
            <td>25</td>
            <td>London</td>
          </tr>
          <tr>
            <td>Carol</td>
            <td>35</td>
            <td>Tokyo</td>
          </tr>
        </table>
      HTML
      @nokogiri_node = Nokogiri::HTML(@html).at('table')
    end

    it 'parses to a matching table' do
      table = described_class.new(@nokogiri_node, type: :html)
      expect(table.headers).to eq(%w[Name Age City])
      expect(table.to_md).to match_markdown(@markdown)
    end
  end

  context 'with empty inputs' do
    it 'handles empty array input' do
      table = described_class.new([], type: :array)
      expect(table.headers).to be_nil
      expect(table).to be_empty
      expect(table.to_md).to eq('')
    end

    it 'handles empty array with headers flag' do
      table = described_class.new([], type: :array, headers: true)
      expect(table.headers).to be_nil
      expect(table).to be_empty
    end

    it 'handles empty string input' do
      table = described_class.new('', type: :markdown)
      expect(table.headers).to be_nil
      expect(table).to be_empty
    end

    it 'handles nil input' do
      table = described_class.new(nil, type: :markdown)
      expect(table.headers).to be_nil
      expect(table).to be_empty
    end
  end

  context 'with nil values in data' do
    before do
      @data_with_nils = [
        ['Name', 'Age', 'City'],
        ['Alice', nil, 'New York'],
        [nil, '25', 'London'],
        ['Carol', '35', nil]
      ]
    end

    it 'preserves nil values' do
      table = described_class.new(@data_with_nils, type: :array, headers: true)
      expected = <<~MARKDOWN

        | Name  | Age  | City     |
        | ----- | ---- | -------- |
        | Alice |      | New York |
        |       | 25   | London   |
        | Carol | 35   |          |
      MARKDOWN
      expect(table.to_md).to match_markdown(expected)
    end
  end

  describe '#each' do
    it 'iterates over each row' do
      names = []
      described_class.new(@markdown).each do |row|
        names << row['Name']
      end
      expect(names).to eq(%w[Alice Bob Carol])
    end

    it 'returns an enumerator when no block is given' do
      enumerator = described_class.new(@markdown).each
      expect(enumerator).to be_an(Enumerator)
      expected = [
        ['Alice', '30', 'New York'],
        ['Bob', '25', 'London'],
        ['Carol', '35', 'Tokyo']
      ]
      expect(enumerator.to_a.map(&:values)).to eq(expected)
    end

    it 'can iterate and modify rows' do
      table = described_class.new(@markdown)
      table.each do |row|
        row['Age'] = row['Age'].to_i + 1
      end
      expected = <<~MARKDOWN
        | Name  | Age | City     |
        | ----- | --- | -------- |
        | Alice | 31  | New York |
        | Bob   | 26  | London   |
        | Carol | 36  | Tokyo    |
      MARKDOWN
      expect(table.to_md).to match_markdown(expected)
    end
  end

  describe '#[]' do
    it 'returns the row at the given index' do
      table = described_class.new(@markdown)
      row = table[1]
      expect(row).to be_a(Marktable::Row)
      expect(row.values).to eq(%w[Bob 25 London])
    end

    it 'returns nil for out of range index' do
      table = described_class.new(@markdown)
      expect(table[99]).to be_nil
    end
  end

  describe '#size and #length' do
    it 'returns the number of rows' do
      table = described_class.new(@markdown)
      expect(table.size).to eq(3)
      expect(table.length).to eq(3)
    end

    it 'returns 0 for empty table' do
      table = described_class.new('')
      expect(table.size).to eq(0)
    end
  end

  describe '#empty?' do
    it 'returns true for an empty table' do
      table = described_class.new('')
      expect(table).to be_empty
    end

    it 'returns false for a non-empty table' do
      table = described_class.new(@markdown)
      expect(table).not_to be_empty
    end
  end

  describe '#to_csv' do
    it 'can convert a table to CSV' do
      table = described_class.new(@markdown)
      expected_csv = <<~CSV
        Name,Age,City
        Alice,30,New York
        Bob,25,London
        Carol,35,Tokyo
      CSV

      expect(table.to_csv).to eq(expected_csv)
    end
  end
end
