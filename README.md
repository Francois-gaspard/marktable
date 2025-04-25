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

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
`
