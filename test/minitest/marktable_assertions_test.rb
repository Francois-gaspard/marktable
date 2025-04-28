# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/marktable_assertions'

class MarktableAssertionsTest < Minitest::Test
  def setup
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

  def test_assert_markdown_match_with_equivalent_tables
    assert_markdown_match(@markdown_table, @equivalent_markdown)
  end

  def test_refute_markdown_match_with_different_tables
    refute_markdown_match(@markdown_table, @different_markdown)
  end

  def test_assert_markdown_match_with_array_format
    assert_markdown_match(@markdown_table, @array_of_hashes, :array)
  end

  def test_refute_markdown_match_with_array_format
    different_array = [
      { 'Name' => 'John', 'Age' => '31' },
      { 'Name' => 'Jane', 'Age' => '25' }
    ]
    refute_markdown_match(@markdown_table, different_array, :array)
  end

  def test_assert_markdown_match_with_html_format
    assert_markdown_match(@markdown_table, @html_table, :html)
  end

  def test_refute_markdown_match_with_html_format
    refute_markdown_match(@markdown_table, @different_html, :html)
  end

  def test_assert_markdown_match_with_custom_message
    custom_message = "Tables should match!"
    error = assert_raises(Minitest::Assertion) do
      assert_markdown_match(@markdown_table, @different_markdown, nil, custom_message)
    end
    
    assert_includes error.message, custom_message
  end
end
