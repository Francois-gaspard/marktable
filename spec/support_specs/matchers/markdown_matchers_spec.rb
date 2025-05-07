# frozen_string_literal: true

require 'spec_helper'
require 'nokogiri'
require 'capybara'

RSpec.describe 'match_markdown matcher' do
  let(:markdown_table) do
    <<~MARKDOWN.chomp
      | Name | Age |
      | ---- | --- |
      | John | 30  |
      | Jane | 25  |
    MARKDOWN
  end

  let(:equivalent_markdown) do
    <<~MARKDOWN.chomp
      | Name | Age |
      | ---- | --- |
      | John | 30   |
      | Jane | 25  |
    MARKDOWN
  end

  let(:different_markdown) do
    <<~MARKDOWN.chomp
      | Name | Age |
      | ---- | --- |
      | John | 31  |
      | Jane | 25  |
    MARKDOWN
  end

  let(:array_of_hashes) do
    [
      { 'Name' => 'John', 'Age' => '30' },
      { 'Name' => 'Jane', 'Age' => '25' }
    ]
  end

  describe 'comparing two markdown tables' do
    it 'passes when the tables are equivalent' do
      expect(equivalent_markdown).to match_markdown(markdown_table)
    end

    it 'fails when the tables are different' do
      expect(different_markdown).not_to match_markdown(markdown_table)
    end
  end

  describe 'comparing an array of hashes with a markdown table' do
    it 'passes when the array matches the table' do
      expect(array_of_hashes).to match_markdown(markdown_table).with_format(:array)
    end

    it 'fails when the array does not match the table' do
      different_array = [
        { 'Name' => 'John', 'Age' => '31' },
        { 'Name' => 'Jane', 'Age' => '25' }
      ]
      expect(different_array).not_to match_markdown(markdown_table).with_format(:array)
    end
  end

  describe 'error messages' do
    it 'provides helpful error message when positive expectation fails' do
      error_message = nil

      begin
        expect(different_markdown).to match_markdown(markdown_table)
      rescue RSpec::Expectations::ExpectationNotMetError => e
        error_message = e.message
      end

      expected_message = <<~MESSAGE.chomp
        Expected markdown table to match:

        Expected:
        | Name | Age |
        | ---- | --- |
        | John | 30  |
        | Jane | 25  |

        Actual:
        | Name | Age |
        | ---- | --- |
        | John | 31  |
        | Jane | 25  |

        Parsed expected data: [{"Name" => "John", "Age" => "30"}, {"Name" => "Jane", "Age" => "25"}]
        Parsed actual data: [{"Name" => "John", "Age" => "31"}, {"Name" => "Jane", "Age" => "25"}]
      MESSAGE
      expect(error_message).to eq(expected_message)
    end

    it 'provides helpful error message when negative expectation fails' do
      error_message = nil

      begin
        expect(equivalent_markdown).not_to match_markdown(markdown_table)
      rescue RSpec::Expectations::ExpectationNotMetError => e
        error_message = e.message
      end

      expected_message = <<~MESSAGE.chomp
        Expected markdown tables to differ, but they match:

        | Name | Age |
        | ---- | --- |
        | John | 30  |
        | Jane | 25  |
      MESSAGE
      expect(error_message).to eq(expected_message)
    end
  end
end

describe 'match_html matcher' do
  let(:html_table) do
    <<~HTML.chomp
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
  end

  let(:different_html) do
    <<~HTML.chomp
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

  let(:equivalent_markdown) do
    <<~MARKDOWN.chomp
      | Name | Age |
      | ---- | --- |
      | John | 30  |
      | Jane | 25  |
    MARKDOWN
  end

  let(:different_markdown) do
    <<~MARKDOWN.chomp
      | Name | Age |
      | ---- | --- |
      | John | 31  |
      | Jane | 25  |
    MARKDOWN
  end

  it 'passes when the HTML tables are equivalent' do
    expect(html_table).to match_markdown(equivalent_markdown).with_format(:html)
  end

  it 'fails when the HTML tables are different' do
    expect(html_table).not_to match_markdown(different_markdown).with_format(:html)
  end

  it 'returns a useful error message when the tables do not match' do
    error_message = nil

    begin
      expect(different_html).to match_markdown(equivalent_markdown).with_format(:html)
    rescue RSpec::Expectations::ExpectationNotMetError => e
      error_message = e.message
    end

    expected = <<~TEXT.chomp
      Expected markdown table to match:

      Expected:
      | Name | Age |
      | ---- | --- |
      | John | 30  |
      | Jane | 25  |

      Actual:
      | Name | Age |
      | ---- | --- |
      | John | 31  |
      | Jane | 25  |

      Parsed expected data: [{"Name" => "John", "Age" => "30"}, {"Name" => "Jane", "Age" => "25"}]
      Parsed actual data: [{"Name" => "John", "Age" => "31"}, {"Name" => "Jane", "Age" => "25"}]
    TEXT
    expect(error_message).to eq(expected)
  end
end

describe 'match_markdown with Nokogiri and Capybara elements' do
  let(:markdown_table) do
    <<~MARKDOWN.chomp
      | Name | Age |
      | ---- | --- |
      | John | 30  |
      | Jane | 25  |
    MARKDOWN
  end

  let(:html_table) do
    <<~HTML.chomp
      <table id="data-provider-systems">
        <thead>
          <tr><th>Name</th><th>Age</th></tr>
        </thead>
        <tbody>
          <tr><td>John</td><td>30</td></tr>
          <tr><td>Jane</td><td>25</td></tr>
        </tbody>
      </table>
    HTML
  end

  it 'works with Nokogiri::XML::Element objects' do
    doc = Nokogiri::HTML(html_table)
    table_element = doc.at_css('table')

    expect(table_element).to match_markdown(markdown_table).with_format(:html)
  end

  # Replace stubbed test with real Capybara elements
  it 'works with Capybara::Node::Element objects', type: :feature do
    # Create a real Capybara session with a simple rack app
    app = lambda { |env| [200, {}, [html_table]] }
    session = Capybara::Session.new(:rack_test, app)
    
    # Visit the page to initialize the session
    session.visit('/')
    
    # Find returns a real Capybara::Node::Element
    table_element = session.find('table#data-provider-systems')
    
    expect(table_element).to match_markdown(markdown_table).with_format(:html)
  end

  it 'works with a table with different structure', type: :feature do
    different_structure_html = <<~HTML
      <table id="data-provider-systems">
        <!-- No thead/tbody structure -->
        <tr><th>Name</th><th>Age</th></tr>
        <tr><td>John</td><td>30</td></tr>
        <tr><td>Jane</td><td>25</td></tr>
      </table>
    HTML
    
    app = lambda { |env| [200, {}, [different_structure_html]] }
    session = Capybara::Session.new(:rack_test, app)
    session.visit('/')
    
    table_element = session.find('table')
    expect(table_element).to match_markdown(markdown_table).with_format(:html)
  end

  it 'works with nested tables in complex HTML', type: :feature do
    complex_html = <<~HTML
      <html>
        <body>
          <div class="container">
            <table id="data-provider-systems" class="table">
              <thead>
                <tr><th>Name</th><th>Age</th></tr>
              </thead>
              <tbody>
                <tr><td>John</td><td>30</td></tr>
                <tr><td>Jane</td><td>25</td></tr>
              </tbody>
            </table>
          </div>
        </body>
      </html>
    HTML
    
    app = lambda { |env| [200, {}, [complex_html]] }
    session = Capybara::Session.new(:rack_test, app)
    session.visit('/')
    
    # Find the table using different selectors
    table_by_id = session.find('#data-provider-systems')
    expect(table_by_id).to match_markdown(markdown_table).with_format(:html)
    
    # Find table within container
    container = session.find('.container')
    table_within = container.find('table')
    expect(table_within).to match_markdown(markdown_table).with_format(:html)
  end
end

describe 'match_markdown with different node types' do
  let(:markdown_table) do
    <<~MARKDOWN.chomp
      | Name | Age |
      | ---- | --- |
      | John | 30  |
      | Jane | 25  |
    MARKDOWN
  end

  let(:html_table) do
    <<~HTML.chomp
      <table id="data-provider-systems">
        <thead>
          <tr><th>Name</th><th>Age</th></tr>
        </thead>
        <tbody>
          <tr><td>John</td><td>30</td></tr>
          <tr><td>Jane</td><td>25</td></tr>
        </tbody>
      </table>
    HTML
  end

  context 'with Nokogiri::XML::Element' do
    it 'works with basic Nokogiri elements' do
      doc = Nokogiri::HTML(html_table)
      table_element = doc.at_css('table')

      expect(table_element).to match_markdown(markdown_table).with_format(:html)
    end

    it 'works with complex Nokogiri elements' do
      complex_html = <<~HTML
        <html>
          <body>
            <div class="container">
              <table id="data-provider-systems" class="table">
                <thead>
                  <tr><th>Name</th><th>Age</th></tr>
                </thead>
                <tbody>
                  <tr><td>John</td><td>30</td></tr>
                  <tr><td>Jane</td><td>25</td></tr>
                </tbody>
              </table>
            </div>
          </body>
        </html>
      HTML

      doc = Nokogiri::HTML(complex_html)
      table_element = doc.at_css('table')

      expect(table_element).to match_markdown(markdown_table).with_format(:html)
    end
  end

  context 'with Capybara::Node::Simple' do
    it 'works with basic table structure' do
      # Capybara::Node::Simple is for static HTML analysis
      element = Capybara.string(html_table)
      table = element.find('table')

      expect(table).to match_markdown(markdown_table).with_format(:html)
    end

    it 'works with different table structures' do
      different_structure = <<~HTML
        <table id="data-provider-systems">
          <!-- No thead/tbody structure -->
          <tr><th>Name</th><th>Age</th></tr>
          <tr><td>John</td><td>30</td></tr>
          <tr><td>Jane</td><td>25</td></tr>
        </table>
      HTML

      element = Capybara.string(different_structure)
      table = element.find('table')

      expect(table).to match_markdown(markdown_table).with_format(:html)
    end

    it 'works with complex nested elements' do
      complex_html = <<~HTML
        <html>
          <body>
            <div class="container">
              <table id="data-provider-systems" class="table">
                <thead>
                  <tr><th>Name</th><th>Age</th></tr>
                </thead>
                <tbody>
                  <tr><td>John</td><td>30</td></tr>
                  <tr><td>Jane</td><td>25</td></tr>
                </tbody>
              </table>
            </div>
          </body>
        </html>
      HTML

      element = Capybara.string(complex_html)
      table = element.find('.container table')

      expect(table).to match_markdown(markdown_table).with_format(:html)
    end
  end

  context 'with Capybara::Node::Element' do
    it 'works with basic Capybara elements', type: :feature do
      # Create a real Capybara session with a simple rack app
      app = lambda { |env| [200, {}, [html_table]] }
      session = Capybara::Session.new(:rack_test, app)
      
      # Visit the page to initialize the session
      session.visit('/')
      
      # Find returns a real Capybara::Node::Element
      table_element = session.find('table#data-provider-systems')
      
      expect(table_element).to match_markdown(markdown_table).with_format(:html)
    end

    it 'works with tables having different structures', type: :feature do
      different_structure_html = <<~HTML
        <table id="data-provider-systems">
          <!-- No thead/tbody structure -->
          <tr><th>Name</th><th>Age</th></tr>
          <tr><td>John</td><td>30</td></tr>
          <tr><td>Jane</td><td>25</td></tr>
        </table>
      HTML
      
      app = lambda { |env| [200, {}, [different_structure_html]] }
      session = Capybara::Session.new(:rack_test, app)
      session.visit('/')
      
      table_element = session.find('table')
      expect(table_element).to match_markdown(markdown_table).with_format(:html)
    end

    it 'works with nested tables in complex HTML', type: :feature do
      complex_html = <<~HTML
        <html>
          <body>
            <div class="container">
              <table id="data-provider-systems" class="table">
                <thead>
                  <tr><th>Name</th><th>Age</th></tr>
                </thead>
                <tbody>
                  <tr><td>John</td><td>30</td></tr>
                  <tr><td>Jane</td><td>25</td></tr>
                </tbody>
              </table>
            </div>
          </body>
        </html>
      HTML
      
      app = lambda { |env| [200, {}, [complex_html]] }
      session = Capybara::Session.new(:rack_test, app)
      session.visit('/')
      
      # Find the table using different selectors
      table_by_id = session.find('#data-provider-systems')
      expect(table_by_id).to match_markdown(markdown_table).with_format(:html)
      
      # Find table within container
      container = session.find('.container')
      table_within = container.find('table')
      expect(table_within).to match_markdown(markdown_table).with_format(:html)
    end
    
    it 'simulates the actual find_by_id scenario', type: :feature do
      # This test simulates finding by ID as mentioned in the original error
      html = <<~HTML
        <html>
          <body>
            <table id="data-provider-systems">
              <thead>
                <tr><th>Name</th><th>Age</th></tr>
              </thead>
              <tbody>
                <tr><td>John</td><td>30</td></tr>
                <tr><td>Jane</td><td>25</td></tr>
              </tbody>
            </table>
          </body>
        </html>
      HTML
      
      app = lambda { |env| [200, {}, [html]] }
      session = Capybara::Session.new(:rack_test, app)
      session.visit('/')
      
      # Similar to the original issue: find_by_id('data-provider-systems')
      actual_table = session.find_by_id('data-provider-systems')
      
      expect(actual_table).to match_markdown(markdown_table).with_format(:html)
    end
  end
end
