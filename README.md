# Marktable

Marktable is a Ruby gem for easily converting between different table formats and testing table content in your specs.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Documentation](#documentation)
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

## Basic Usage

### RSpec Matchers

```ruby
# In your spec_helper.rb
require 'marktable/rspec'

# In your specs - compare tables across formats
expect(markdown_table).to match_markdown(expected_markdown)

html_table = page.find('#users-table')
expect(html_table).to match_markdown(expected_markdown)
```

### Converting Between Formats

```ruby
# From markdown to other formats
markdown = <<~MARKDOWN
  | Name | Age  |
  |------|----- |
  | Alice | 30  |
  | Bob   | 25  |
MARKDOWN

table = Marktable.from_markdown(markdown)

table.to_a # Array of hashes
table.to_csv # CSV string
table.to_html # HTML table

# From arrays or hashes to markdown
data = [{ 'Name' => 'Alice', 'Age' => '30' }]
Marktable.from_array(data).to_md # Markdown table
```

## Documentation

* [Full Examples](docs/examples.md) - Detailed usage examples
* [API Documentation](docs/api_documentation.md) - Complete API reference
=======
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

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
`
