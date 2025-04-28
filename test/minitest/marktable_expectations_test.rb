# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../lib/minitest/marktable_expectations'

describe 'Marktable Expectations' do
  before do
    @markdown_table = <<~MARKDOWN.chomp
      | Name | Age |
      | ---- | --- |
      | John | 30  |
      | Jane | 25  |
    MARKDOWN

    @equivalent_markdown = <<~MARKDOWN.chomp
      | Name | Age |
      | ---- | --- |
      | John | 30   |
      | Jane | 25  |
    MARKDOWN

    @different_markdown = <<~MARKDOWN.chomp
      | Name | Age |
      | ---- | --- |
      | John | 31  |
      | Jane | 25  |
    MARKDOWN

    @array_of_hashes = [
      { 'Name' => 'John', 'Age' => '30' },
      { 'Name' => 'Jane', 'Age' => '25' }
    ]

    @html_table = <<~HTML.chomp
      <table>
        <thead>
          <tr><th>Name</th><th>Age</th></tr>
        </thead>
        <tbody>
          <tr><td>John</td><td>30</td></tr>
          <tr><td>Jane</td><td>25</td></tr>
        </tbody>
      </table>
    HTML

    @different_html = <<~HTML.chomp
      <table>
        <thead>
          <tr><th>Name</th><th>Age</th></tr>
        </thead>
        <tbody>
          <tr><td>John</td><td>31</td></tr>
          <tr><td>Jane</td><td>25</td></tr>
        </tbody>
      </table>
    HTML
  end

  describe 'must_match_markdown expectation' do
    it 'passes when markdown tables are equivalent' do
      _(@equivalent_markdown).must_match_markdown @markdown_table
    end
    
    it 'fails when markdown tables are different' do
      # Using _{}.must_raise instead of proc{}.must_raise
      _{
        _(@different_markdown).must_match_markdown @markdown_table
      }.must_raise Minitest::Assertion
    end
    
    it 'passes when array matches markdown' do
      _(@array_of_hashes.with_format(:array)).must_match_markdown @markdown_table
    end
    
    it 'passes when HTML table matches markdown' do
      _(@html_table.with_format(:html)).must_match_markdown @markdown_table
    end
    
    it 'provides a helpful error message when expectation fails' do
      error = _{
        _(@different_markdown).must_match_markdown @markdown_table
      }.must_raise Minitest::Assertion
      
      expected_error_content = "Expected markdown table to match"
      _(error.message).must_include expected_error_content
    end
  end
  
  describe 'wont_match_markdown expectation' do
    it 'passes when markdown tables are different' do
      _(@different_markdown).wont_match_markdown @markdown_table
    end
    
    it 'fails when markdown tables are equivalent' do
      _{
        _(@equivalent_markdown).wont_match_markdown @markdown_table
      }.must_raise Minitest::Assertion
    end
    
    it 'passes when array differs from markdown' do
      different_array = [
        { 'Name' => 'John', 'Age' => '31' },
        { 'Name' => 'Jane', 'Age' => '25' }
      ]
      _(different_array.with_format(:array)).wont_match_markdown @markdown_table
    end
    
    it 'passes when HTML table differs from markdown' do
      _(@different_html.with_format(:html)).wont_match_markdown @markdown_table
    end
  end

  describe 'format handling' do
    it 'correctly handles multiple format specifications in a single test' do
      # First expectation
      _(@array_of_hashes.with_format(:array)).must_match_markdown @markdown_table
      
      # Second expectation (should not inherit format from first)
      _(@html_table.with_format(:html)).must_match_markdown @markdown_table
      
      # Third expectation with different actual but same format
      different_array = [
        { 'Name' => 'John', 'Age' => '31' },
        { 'Name' => 'Jane', 'Age' => '25' }
      ]
      _(different_array.with_format(:array)).wont_match_markdown @markdown_table
    end
  end
end
