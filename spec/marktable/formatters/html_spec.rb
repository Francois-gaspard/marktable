# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Marktable::Formatters::HTML do
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

    it 'returns an HTML table string' do
      expected = <<~HTML.gsub(/^\s+/, '').strip
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
            <tr>
              <td>Carol</td>
              <td>35</td>
              <td>Tokyo</td>
            </tr>
          </tbody>
        </table>
      HTML

      expect(@table.to_html).to eq(expected)
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

    it 'returns an HTML table string without thead' do
      expected = <<~HTML.gsub(/^\s+/, '').strip
        <table><tbody>
            <tr>
              <td>30</td>
              <td>New York</td>
            </tr>
            <tr>
              <td>25</td>
              <td>London</td>
            </tr>
            <tr>
              <td>35</td>
              <td>Tokyo</td>
            </tr>
        </tbody></table>
      HTML

      expect(@table.to_html).to eq(expected)
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

    it 'returns an HTML table with empty cells' do
      expected = <<~HTML.gsub(/^\s+/, '').strip
        <table>
          <thead><tr>
            <th>Name</th>
            <th>Age</th>
            <th>City</th>
          </tr></thead>
          <tbody>
            <tr>
              <td>Alice</td>
              <td></td>
              <td>New York</td>
            </tr>
            <tr>
              <td>Bob</td>
              <td>25</td>
              <td></td>
            </tr>
            <tr>
              <td>Carol</td>
              <td>35</td>
              <td>Tokyo</td>
            </tr>
          </tbody>
        </table>
      HTML

      expect(@table.to_html).to eq(expected)
    end
  end

  context 'with HTML special characters that need escaping' do
    before do
      markdown = <<~MARKDOWN
        | Element | <b>Example</b>                            |
        | ------- | ----------------------------------------- |
        | Link    | <a href="https://example.com">Example</a> |
        | Entity  | R&D Department                            |
        | Script  | <script>alert('XSS')</script>             |
      MARKDOWN

      @table = Marktable.from_markdown(markdown)
    end

    it 'correctly escapes HTML special characters' do
      expected = <<~HTML.gsub(/^\s+/, '').strip
        <table>
          <thead><tr>
            <th>Element</th>
            <th>&lt;b&gt;Example&lt;/b&gt;</th>
          </tr></thead>
          <tbody>
            <tr>
              <td>Link</td>
              <td>&lt;a href="https://example.com"&gt;Example&lt;/a&gt;</td>
            </tr>
            <tr>
              <td>Entity</td>
              <td>R&amp;D Department</td>
            </tr>
            <tr>
              <td>Script</td>
              <td>&lt;script&gt;alert('XSS')&lt;/script&gt;</td>
            </tr>
          </tbody>
        </table>
      HTML

      expect(@table.to_html).to eq(expected)
    end
  end

  context 'with multiline content in cells' do
    before do
      markdown = <<~MARKDOWN
        | Name        | Bio                                              |
        | ----------- | ------------------------------------------------ |
        | John Smith  | Software Engineer\\nSpecializes in Ruby          |
        | Jane Doe    | Product Manager\\nMBA Graduate\\nTech Enthusiast |
      MARKDOWN

      @table = Marktable.from_markdown(markdown)
    end

    it 'properly formats multiline cell content with <br> tags' do
      expected = <<~HTML.gsub(/^\s+/, '').strip
        <table>
          <thead><tr>
            <th>Name</th>
            <th>Bio</th>
          </tr></thead>
          <tbody>
            <tr>
              <td>John Smith</td>
              <td>Software Engineer<br>Specializes in Ruby</td>
            </tr>
            <tr>
              <td>Jane Doe</td>
              <td>Product Manager<br>MBA Graduate<br>Tech Enthusiast</td>
            </tr>
          </tbody>
        </table>
      HTML

      expect(@table.to_html).to eq(expected)
    end
  end
end
