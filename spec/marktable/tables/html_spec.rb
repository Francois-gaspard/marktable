# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Marktable::Table do
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
      
      @markdown = <<~MARKDOWN
        | Name  | Age | City     |
        | ----- | --- | -------- |
        | Alice | 30  | New York |
        | Bob   | 25  | London   |
        | Carol | 35  | Tokyo    |
      MARKDOWN
    end

    it 'parses to a matching table' do
      table = described_class.new(@nokogiri_node, type: :html)
      expect(table.headers).to eq(%w[Name Age City])
      expect(table.to_md).to match_markdown(@markdown)
    end
  end

  context 'with HTML that contains whitespace and newline issues' do
    it 'handles newlines in cell content' do
      html_with_newlines = <<~HTML
        <table>
          <tr>
            <th>Recipe</th>
            <th>Cuisine</th>
            <th>Cooking Methods</th>
          </tr>
          <tr>
            <td>Lasagna</td>
            <td>Italian</td>
            <td>Bake
                Simmer</td>
          </tr>
        </table>
      HTML

      expected_markdown = <<~MARKDOWN
        | Recipe  | Cuisine | Cooking Methods |
        | ------- | ------- | --------------- |
        | Lasagna | Italian | Bake Simmer     |
      MARKDOWN

      table = described_class.new(html_with_newlines, type: :html)
      expect(table.to_md).to match_markdown(expected_markdown)
    end

    it 'preserves spaces in JSON content' do
      html_with_json = <<~HTML
        <table>
          <tr>
            <th>Recipe</th>
            <th>Recipe Notes</th>
          </tr>
          <tr>
            <td>Chocolate Cake</td>
            <td>
              {   "preparation_time": "45 minutes" }
            </td>
          </tr>
        </table>
      HTML

      expected_markdown = <<~MARKDOWN
        | Recipe         | Recipe Notes                           |
        | -------------- | -------------------------------------- |
        | Chocolate Cake | { "preparation_time": "45 minutes" }   |
      MARKDOWN

      table = described_class.new(html_with_json, type: :html)
      expect(table.to_md).to match_markdown(expected_markdown)
    end

    it 'handles complex nested HTML with JSON and text' do
      complex_html = <<~HTML
        <table>
          <tr>
            <th>Book Title</th>
            <th>Publication Details</th>
            <th>Genres</th>
          </tr>
          <tr>
            <td>The Great Adventure</td>
            <td>
              <div data-controller="copyable-content">
                <div class="float-right">
                  <a style="cursor: pointer;" data-action="click->copyable-content#perform" title="Copy">
                    <i class="material-icons">content_copy</i>
                  </a>
                </div>
                <pre data-copyable-content-target="copyableData" title='{   "year": 2023, "publisher": "Bookworm Press" }'>{   "year": 2023, "publisher": "Bookworm Press" }</pre>
              </div>
            </td>
            <td>
              <h2>
                <span class="badge rounded-pill bg-success">adventure</span>
                <span class="badge rounded-pill bg-success">fantasy</span>
              </h2>
            </td>
          </tr>
        </table>
      HTML

      expected_markdown = <<~MARKDOWN
        | Book Title          | Publication Details                                          | Genres            |
        | ------------------- | ------------------------------------------------------------ | ----------------- |
        | The Great Adventure | content_copy { "year": 2023, "publisher": "Bookworm Press" } | adventure fantasy |
      MARKDOWN

      table = described_class.new(complex_html, type: :html)
      expect(table.to_md).to match_markdown(expected_markdown)
    end

    it 'handles whitespace in tables with multiple cells and rows' do
      html_with_whitespace = <<~HTML
        <table>
          <tr>
            <th>  Planet  </th>
            <th>  Features   </th>
          </tr>
          <tr>
            <td>   Mars    </td>
            <td>
              Red surface
              with dust storms
              and   polar   ice caps
            </td>
          </tr>
          <tr>
            <td>Venus</td>
            <td>Dense atmosphere</td>
          </tr>
        </table>
      HTML

      expected_markdown = <<~MARKDOWN
        | Planet | Features                                        |
        | ------ | ----------------------------------------------- |
        | Mars   | Red surface with dust storms and polar ice caps |
        | Venus  | Dense atmosphere                                |
      MARKDOWN

      table = described_class.new(html_with_whitespace, type: :html)
      expect(table.to_md).to match_markdown(expected_markdown)
    end
  end
end
