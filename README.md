# Marktable

Marktable is a Ruby gem for easily converting between different table formats and testing table content in your specs.

[View the full API documentation](docs/api_documentation.md)

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  - [RSpec Matchers](#rspec-matchers)
  - [Converting Between Table Formats](#converting-between-table-formats)
  - [Working with Tables](#working-with-tables)
- [Unsupported](#unsupported)
- [License](#license)

## Features

* RSpec matchers to compare tables across formats
* Convert between multiple table formats:
  - Markdown tables
  - Arrays of arrays
  - Arrays of hashes
  - CSV
  - HTML tables

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'marktable'
```

And then execute:

```
$ bundle install
```

Or install it yourself:

```
$ gem install marktable
```

## Usage

### RSpec Matchers

Marktable includes RSpec matchers to help test tables across different formats in a readable, visual manner.

#### Setup

Add this to your `spec_helper.rb`:

```ruby
require 'marktable/rspec'
```

#### Comparing Markdown Tables, CSV, Arrays, Hashes and html to Markdown tables

```ruby
expect(markdown_table1).to match_markdown(markdown_table2)
```

#### Comparing Arrays with Markdown

```ruby
markdown_table = <<~MARKDOWN
  | Name  | Age | City     |
  | ----- | --- | -------- |
  | Alice | 30  | New York |
  | Bob   | 25  | London   |
MARKDOWN

data = [
  { 'Name' => 'John', 'Age' => '30' },
  { 'Name' => 'Jane', 'Age' => '25' }
]

expect(data).to match_markdown(markdown_table)
```

#### Comparing HTML Tables with Markdown

```ruby
html_table = <<~HTML
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

expect(html_table).to match_markdown(markdown_table).with_format(:html)
```

The matcher provides detailed error messages when tables don't match:

```
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
```

### Converting Between Table Formats

#### From Markdown

```ruby
# Create a table from markdown
markdown = <<~MARKDOWN
  | Name  | Age | City     |
  | ----- | --- | -------- |
  | Alice | 30  | New York |
  | Bob   | 25  | London   |
MARKDOWN

table = Marktable.from_markdown(markdown)

# Convert to array of hashes
puts table.to_a 
# {"Name" => "Alice", "Age" => "30", "City" => "New York"}
# {"Name" => "Bob", "Age" => "25", "City" => "London"}

# Convert to CSV
puts table.to_csv
# Name,Age,City
# Alice,30,New York
# Bob,25,London

# Convert back to markdown
puts table.to_md
# | Name  | Age | City     |
# | ----- | --- | -------- |
# | Alice | 30  | New York |
# | Bob   | 25  | London   |

puts table.to_html
# <table>
#   <thead><tr>
#     <th>Name</th>
#     <th>Age</th>
#     <th>City</th>
#   </tr></thead>
#   <tbody>
#   <tr>
#     <td>Alice</td>
#     <td>30</td>
#     <td>New York</td>
#   </tr>
#   <tr>
#     <td>Bob</td>
#     <td>25</td>
#     <td>London</td>
#   </tr>
#   </tbody>
# </table>
```

#### From Arrays

Takes an array of arrays or an array of hashes and converts them to a markdown table.
```ruby
# From array of arrays
arrays = [
  ['Name', 'Age', 'City'],
  ['Alice', '30', 'New York'],
  ['Bob', '25', 'London']
]
puts Marktable.from_array(arrays).to_md
# | Name  | Age | City     |
# | Alice | 30  | New York |
# | Bob   | 25  | London   |

# From array of hashes
hashes = [
  { 'Name' => 'Alice', 'Age' => '30', 'City' => 'New York' },
  { 'Name' => 'Bob', 'Age' => '25', 'City' => 'London' }
]
puts  Marktable.from_array(hashes).to_md
# | Name  | Age | City     |
# | ----- | --- | -------- |
# | Alice | 30  | New York |
# | Bob   | 25  | London   |
```

#### From CSV

```ruby
csv_data = <<~CSV
  Name,Age,City
  Alice,30,New York
  Bob,25,London
CSV

table = Marktable.from_csv(csv_data, headers: true)

# Or with a CSV::Table
csv_table = CSV::Table.parse(csv_data)
table = Marktable.from_csv(csv_table)
```

#### From HTML

```ruby
html = <<~HTML
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

puts Marktable.from_html(html).to_md
# | Name  | Age | City     |
# |-------| --- | -------- |
# | Alice | 30  | New York |
# | Bob   | 25  | London   |

```

### Working with Tables

```ruby
# Access rows by index
row = table[0]  # First row
row['Name']     # => "Alice"

# Iterate through rows
table.each do |row|
  puts "#{row['Name']} is #{row['Age']} years old"
end

# Get table size
table.size      # => 2
table.empty?    # => false

# Modify rows

table.map do |row|
  row['Age'] = row['Age'].to_i + 1
end

puts table.to_md
# | Name  | Age | City     |
# | ----- | --- | -------- |
# | Alice | 31  | New York |
# | Bob   | 26  | London   |
```

## Unsupported:

* Nested tables
* Complex HTML tables (e.g., with colspan or rowspan)
* Custom delimiters in CSV

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
`
