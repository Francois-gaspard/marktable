# Marktable


A powerful Ruby library for parsing, manipulating, and generating Markdown tables with an elegant and intuitive API.

## 📚 Overview

Marktable allows you to seamlessly work with Markdown tables using familiar Ruby data structures. Whether you're parsing tables from Markdown documents, generating tables for documentation, or manipulating tabular data, Marktable provides simple yet powerful tools for all your Markdown table needs.

## ✨ Features

- **Custom RSpec matcher** for testing Markdown-like data structures (including html tables) against expected Markdown output
- **Parse** Markdown tables into Ruby data structures (arrays or hashes)
- **Generate** beautifully formatted Markdown tables from Ruby objects
- **Filter** and **transform** table data with Ruby's familiar block syntax
- **Auto-detect** headers from properly formatted Markdown tables
- **Handle** tables with or without headers
- **Support** for mismatched columns and keys in data
- **Convert** between array-based and hash-based representations

## Not supported
- Non-string values (E.g. complex objects) in the table rows. 

## 📦 Installation

Add this line to your application's Gemfile:

```ruby
gem 'marktable'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install marktable
```

## 🚀 Quick Start

### Main use case (Rspec only at this time)

This gem started as a pet project aiming at:
- Simplifying the process of testing html table content
- Making these specs more developer-friendly, with a very readable format


```ruby
visit my_path
actual_table = page.find('#my-table')
expected_table = <<~MARKDOWN
  | Name  | Age | City     |
  | ----- | --- | -------- |
  | John  | 30  | New York |
  | Jane  | 25  | Boston   |
  | Bob   | 17  | Chicago  |
MARKDOWN

expect(actual_table).to match_markdown(expected_table)
```

In case of semantical mismatch, the matcher will show an easy to verify markdown representation of the tables:

```markdown
        Expected markdown table to match:
        
        Expected:
        | Name  | Age | City     |
        | ----- | --- | -------- |
        | John  | 30  | New York |
        | Jane  | 25  | Boston   |
        | Bob   | 17  | Chicago  |
        
        Actual:
        | Name | Age |
        | ---- | --- |
        | John | 31  |
        | Jane | 25  |
        
        Parsed expected data: [{"Name" => "John", "Age" => "30"}, {"Name" => "Jane", "Age" => "25"}, {"Name" => "Bob", "Age" => "17"}]
        Parsed actual data: [{"Name" => "John", "Age" => "31"}, {"Name" => "Jane", "Age" => "25"}]
```



### Parsing a Markdown Table

```ruby
require 'marktable'

markdown_table = <<~MARKDOWN
  | Name  | Age | City     |
  | ----- | --- | -------- |
  | John  | 30  | New York |
  | Jane  | 25  | Boston   |
MARKDOWN

# Parse into an array of hashes (with auto-detected headers)
data = Marktable.parse(markdown_table)
# => [
#      {"Name"=>"John", "Age"=>"30", "City"=>"New York"},
#      {"Name"=>"Jane", "Age"=>"25", "City"=>"Boston"}
#    ]

# Access data easily
puts data.first["Name"]  # => "John"
```

### Generating a Markdown Table

```ruby
# Create a new table and add rows
table = Marktable.generate do |t|
  t << {"Name" => "John", "Age" => "30", "City" => "New York"}
  t << {"Name" => "Jane", "Age" => "25", "City" => "Boston"}
  t << {"Name" => "Bob", "Age" => "17", "City" => "Chicago"}
end

puts table
# | Name | Age | City     |
# | ---- | --- | -------- |
# | John | 30  | New York |
# | Jane | 25  | Boston   |
# | Bob  | 17  | Chicago  |
```

## 📖 Usage Guide

### Working with Table Objects

Create a table object for more advanced operations:

```ruby
# Create from a markdown string
table = Marktable.new(markdown_table)

# Or create from array data
array_data = [
  ["Name", "Age", "City"],
  ["John", "30", "New York"],
  ["Jane", "25", "Boston"],
  ["Bob", "17", "Chicago"]
]
table = Marktable.new(array_data, headers: true)

# Or with auto-detected headers
array_data = [
  { "Name" => "John", "Age" => "30", "City" => "New York" },
  { "Name" => "Jane", "Age" => "25", "City" => "Boston" },
  { "Name" => "Bob", "Age" => "17", "City" => "Chicago" }
]
table = Marktable.new(array_data)
```

### Filtering Rows

Filter rows using pattern matching or blocks:

```ruby
# Filter with a regex pattern
nyc_residents = table.filter(/New York/)

# Filter with a block
adults = table.filter do |row|
  row["Age"].to_i >= 18
end

puts adults
# | Name | Age | City     |
# | ---- | --- | -------- |
# | John | 30  | New York |
# | Jane | 25  | Boston   |
```

### Transforming Data

Transform table data with the map method:

```ruby
# Add 5 years to everyone's age
older = table.map do |row|
  row.merge("Age" => (row["Age"].to_i + 5).to_s)
end

puts older
# | Name | Age | City     |
# | ---- | --- | -------- |
# | John | 35  | New York |
# | Jane | 30  | Boston   |
# | Bob  | 22  | Chicago  |
```

### Working with Arrays

Use arrays instead of hashes for row data:

```ruby
# Create a table with array rows
table = Marktable.new([], headers: false)
table << ["John", "30", "New York"]
table << ["Jane", "25", "Boston"]

puts table
# | John | 30  | New York |
# | Jane | 25  | Boston   |
```

### Mixed Row Types

Marktable can handle mixed row types (arrays and hashes):

```ruby
table = Marktable.generate do |t|
  t << {"Name" => "John", "Age" => "30", "City" => "New York"}
  t << ["Jane", "25", "Boston"]  # Array with same column count
end

puts table
# | Name | Age | City     |
# | ---- | --- | -------- |
# | John | 30  | New York |
# | Jane | 25  | Boston   |
```

## 🧪 Testing with Custom Matchers

Marktable includes a custom RSpec matcher, `match_markdown`, to make testing Markdown-compatible data structures simple and reliable.

### Using the `match_markdown` Matcher

First, require the matcher in your spec_helper.rb or in the specific test file:

```ruby
require 'marktable/rspec'
```

#### Testing Markdown Table Output

```ruby
RSpec.describe ReportGenerator do
  describe "#generate_customer_table" do
    it "generates the expected customer table" do
      actual = ReportGenerator.new(customers).generate_table
      # Presume actual contains:
      # [
      #   { id: 1, name: "John Smith", status: "Active" },
      #   { id: 2, name: "Jane Doe", status: "Pending" }
      # ]
      
      expected = <<~MARKDOWN
        | ID | Name       | Status  |
        | -- | ---------- | ------- |
        | 1  | John Smith | Active  |
        | 2  | Jane Doe   | Pending |
      MARKDOWN
      
      expect(result).to match_markdown(expected)
    end
  end
end
```

#### Testing HTML Table Output

The `match_markdown` matcher can also compare HTML tables by extracting their semantic content:

```ruby
RSpec.describe HtmlReportGenerator do
  describe "#generate_sales_report" do
    it "generates the expected HTML table" do
      sales_data = [
        { product: "Widget A", quantity: 150, revenue: "$3,000" },
        { product: "Widget B", quantity: 75, revenue: "$1,875" }
      ]
      
      generator = HtmlReportGenerator.new(sales_data)
      html_output = generator.generate_sales_report
      
      # The matcher extracts the data structure from both the HTML and expected markdown
      expected = <<~MARKDOWN
        | Product  | Quantity | Revenue |
        | -------- | -------- | ------- |
        | Widget A | 150      | $3,000  |
        | Widget B | 75       | $1,875  |
      MARKDOWN
      
      # This will pass even though one is HTML and one is Markdown!
      expect(html_output).to match_markdown(expected)
    end
  end
end
```

#### Testing API JSON Responses

The matcher is also helpful when testing APIs that return tabular data:

```ruby
RSpec.describe "Products API" do
  describe "GET /api/products" do
    it "returns products in the expected format" do
      # Setup test data and make request
      get "/api/products"
      
      # Parse JSON response
      json_response = JSON.parse(response.body)
      
      # Convert API response to a table
      table = Marktable.new(json_response)
      
      expected = <<~MARKDOWN
        | id | name        | category | price  |
        | -- | ----------- | -------- | ------ |
        | 1  | Product One | Books    | $19.99 |
        | 2  | Product Two | Games    | $59.99 |
      MARKDOWN
      
      expect(table).to match_markdown(expected)
    end
  end
end
```

The `match_markdown` matcher compares tables semantically rather than character-by-character, which means:

- It ignores differences in whitespace padding
- It handles different column ordering in hash-based tables
- It works with both HTML and Markdown table formats
- It provides clear error messages showing the differences between tables

## 📋 API Reference

### Class Methods

- `Marktable.parse(table, headers: nil)` - Parse table string or array into an array of hashes/arrays
- `Marktable.new(table, headers: nil)` - Create a new Table object
- `Marktable.parse_line(row)` - Parse a single markdown row into an array
- `Marktable.generate { |t| ... }` - Generate a table with a block

### Instance Methods

- `table.to_a` - Convert table to array of hashes/arrays
- `table.to_s` / `table.generate` - Generate markdown representation
- `table.empty?` - Check if table is empty
- `table.column_count` - Get column count
- `table << row_data` - Add a row to the table
- `table.filter(pattern = nil) { |row| ... }` - Filter rows by pattern or block
- `table.map { |row| ... }` - Transform rows with a block

## 🧪 Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## 🤝 Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/marktable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/yourusername/marktable/blob/main/CODE_OF_CONDUCT.md).

1. Fork the repository
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request

## 📄 License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
