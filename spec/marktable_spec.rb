# frozen_string_literal: true

require 'spec_helper'
require 'marktable'

RSpec.describe Marktable do
  describe '.from_markdown' do
    it 'creates a Table with markdown type' do
      actual = Marktable.from_markdown(headerless_markdown).to_a

      expected = arrays

      expect(actual).to eq(expected)
    end

    it 'detects headers' do
      actual = Marktable.from_markdown(markdown).to_a

      expected = hashes

      expect(actual).to eq(expected)
    end

    it 'can ignore headers' do
      actual = Marktable.from_markdown(markdown, headers: false).to_a

      expected = arrays

      expect(actual).to eq(expected)
    end

    it 'can force headers' do
      actual = Marktable.from_markdown(headerless_markdown, headers: true).to_a

      expected = hashes

      expect(actual).to eq(expected)
    end
  end

  describe '.from_csv' do
    it 'creates a Table with csv type' do
      csv = <<~CSV
        Name,Age,City
        Alice,30,New York
        Bob,25,London
      CSV

      actual = Marktable.from_csv(csv).to_a

      expected = [
        ['Name', 'Age', 'City'],
        ['Alice', '30', 'New York'],
        ['Bob', '25', 'London']
      ]

      expect(actual).to eq(expected)
    end

    it 'accepts headers parameter' do
      actual = Marktable.from_csv(csv, headers: true).to_a

      expected = hashes

      expect(actual).to eq(expected)
    end
  end

  describe '.from_array' do
    context 'with array of arrays' do
      it 'creates a Table with array type' do
        actual = Marktable.from_array(arrays).to_md

        expected = headerless_markdown

        expect(actual).to match_markdown(expected)
      end

      it 'accepts headers parameter' do
        actual = Marktable.from_array(arrays, headers: true).to_md

        expected = markdown

        expect(actual).to match_markdown(expected)
      end
    end

    context 'with array of hashes' do
      it 'creates a Table with array type' do
        actual = Marktable.from_array(hashes).to_md

        expected = markdown

        expect(actual).to match_markdown(expected)
      end

      # Not supported. Not sure if there is any use case for it.
      # Converting hashes to arrays might generate unexpected results due to ordering.
      it 'ignores headers parameter' do
        actual = Marktable.from_array(hashes, headers: false).to_md

        expected = markdown

        expect(actual).to match_markdown(expected)
      end
    end
  end

  describe '.from_html' do
    context 'with headers' do
      it 'creates a Table with html type' do
        actual = Marktable.from_html(html).to_a

        expected = hashes

        expect(actual).to eq(expected)
      end
    end

    context 'without headers' do
      it 'creates a Table with html type' do
        actual = Marktable.from_html(headerless_html).to_a

        expected = arrays

        expect(actual).to eq(expected)
      end
    end
  end

  def arrays
    [
      ['Name', 'Age', 'City'],
      ['Alice', '30', 'New York'],
      ['Bob', '25', 'London']
    ]
  end

  def csv
    <<~CSV
      Name,Age,City
      Alice,30,New York
      Bob,25,London
    CSV
  end

  def hashes
    [
      { 'Name' => 'Alice', 'Age' => '30', 'City' => 'New York' },
      { 'Name' => 'Bob', 'Age' => '25', 'City' => 'London' }
    ]
  end

  def markdown
    <<~MARKDOWN
      | Name  | Age | City     |
      | ----- | --- | -------- |
      | Alice | 30  | New York |
      | Bob   | 25  | London   |
    MARKDOWN
  end

  def headerless_markdown
    <<~MARKDOWN
      | Name  | Age | City     |
      | Alice | 30  | New York |
      | Bob   | 25  | London   |
    MARKDOWN
  end

  def html
    <<~HTML
      <table>
        <thead><tr>
          <th>Name</th>
          <th>Age</th>
          <th>City</th>
        </tr></thead>
        <tbody>
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
        </tbody>
      </table>
    HTML
  end

  def headerless_html
    <<~HTML
      <table>
        <tbody>
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
        </tbody>
      </table>
    HTML
  end
end
