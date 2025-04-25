# Marktable API Documentation

## Marktable Module

The `Marktable` module provides factory methods for creating table objects from different input formats.

### Methods

#### `from_markdown(table, headers: nil)`

Creates a new `Table` object from markdown-formatted text.

**Parameters:**
- `table` (String): A string containing a markdown-formatted table
- `headers` (Boolean, optional): Whether to treat the first row as headers
  - `nil` (default): Auto-detect headers based on the presence of separator row
  - `true`: Force treat the first row as headers
  - `false`: Force treat all rows as data (no headers)

**Returns:** A new `Marktable::Table` object

**Example:**
```ruby
markdown = <<~MARKDOWN
  | Name  | Age | City     |
  | ----- | --- | -------- |
  | Alice | 30  | New York |
  | Bob   | 25  | London   |
MARKDOWN

table = Marktable.from_markdown(markdown)
# Creates a table with headers: ["Name", "Age", "City"]
```

#### `from_csv(table, headers: nil)`

Creates a new `Table` object from CSV data.

**Parameters:**
- `table` (String, CSV::Table): CSV data as a string or CSV::Table object
- `headers` (Boolean, optional): Whether to treat the first row as headers
  - `nil` (default): `false` for String-type table. Complies with the CSV::Table object otherwise.
  - `true`: Use the first row as headers
  - `false`: Use all rows as data (no headers)

**Returns:** A new `Marktable::Table` object

**Example:**
```ruby
csv_data = <<~CSV
  Name,Age,City
  Alice,30,New York
  Bob,25,London
CSV

table = Marktable.from_csv(csv_data, headers: true)
# Creates a table with headers: ["Name", "Age", "City"]
```

#### `from_array(table, headers: nil)`

Creates a new `Table` object from an array of arrays or an array of hashes.

**Parameters:**
- `table` (Array): An array of arrays or an array of hashes
- `headers` (Boolean, optional): Whether to treat the first row as headers (for array of arrays)
  - `nil` (default): Use the first row as data
  - `true`: Use the first row as headers
  - `false`: Use all rows as data (no headers)
  - Note: This parameter is ignored for array of hashes and always considered `true`

**Returns:** A new `Marktable::Table` object

**Example with array of arrays:**
```ruby
arrays = [
  ['Name', 'Age', 'City'],
  ['Alice', '30', 'New York'],
  ['Bob', '25', 'London']
]
table = Marktable.from_array(arrays, headers: true)
# Creates a table with headers: ["Name", "Age", "City"]
```

**Example with array of hashes:**
```ruby
hashes = [
  { 'Name' => 'Alice', 'Age' => '30', 'City' => 'New York' },
  { 'Name' => 'Bob', 'Age' => '25', 'City' => 'London' }
]
table = Marktable.from_array(hashes)
# Creates a table with headers: ["Name", "Age", "City"]
```

#### `from_html(table)`

Creates a new `Table` object from an HTML table string or Nokogiri node.

**Parameters:**
- `table` (String, Nokogiri::Node): HTML table as a string or Nokogiri node

**Note**: Header presence is inferred from the html.

**Returns:** A new `Marktable::Table` object

**Example:**
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

table = Marktable.from_html(html)
# Creates a table with headers: ["Name", "Age", "City"]
```

## Marktable::Table Class

The `Table` class represents a table and provides methods for manipulation and conversion between formats.

### Constructor

#### `initialize(data, type: nil, headers: nil)`

Creates a new Table object from the given data.

**Parameters:**
- `data`: The table data in any supported format
- `type` (Symbol): The format of the input data. One of:
  - `:markdown`: Markdown-formatted text
  - `:csv`: CSV string or CSV::Table
  - `:array`: Array of arrays or array of hashes 
  - `:html`: HTML table string or Nokogiri node
- `headers` (Boolean, optional): Whether to treat the first row as headers
  - `nil` (default): Auto-detect based on input type
  - `true`: Force treat the first row as headers
  - `false`: Force treat all rows as data (no headers)

**Returns:** A new `Marktable::Table` object

### Instance Methods

#### `headers`

Gets the table headers.

**Returns:** Array of header strings or nil if no headers

#### `rows`

Gets all rows in the table.

**Returns:** Array of Row objects

#### `[](index)`

Gets the row at the specified index.

**Parameters:**
- `index` (Integer): The zero-based index of the row to retrieve

**Returns:** A Row object or nil if the index is out of bounds

**Example:**
```ruby
row = table[0]  # Get first row
name = row['Name']  # Get value from column 'Name'
```

#### `each(&block)`

Iterates through each row of the table.

**Parameters:**
- `&block`: Block to execute for each row

**Returns:** The table object if a block is given, otherwise an Enumerator

**Example:**
```ruby
table.each do |row|
  puts "#{row['Name']} is #{row['Age']} years old"
end
```

#### `size`, `length`

Gets the number of rows in the table.

**Returns:** Integer representing the number of rows

#### `empty?`

Checks if the table has no rows.

**Returns:** Boolean indicating whether the table is empty

#### `to_a`

Converts the table to an array.

**Returns:** 
- If the table has headers: Array of hashes where keys are header values
- If the table has no headers: Array of arrays

**Example with headers:**
```ruby
table.to_a
# => [{"Name"=>"Alice", "Age"=>"30", "City"=>"New York"}, {"Name"=>"Bob", "Age"=>"25", "City"=>"London"}]
```

**Example without headers:**
```ruby
table.to_a
# => [["Name", "Age", "City"], ["Alice", "30", "New York"], ["Bob", "25", "London"]]
```

#### `to_md`

Converts the table to a markdown-formatted string.

**Returns:** String containing markdown table

**Example:**
```ruby
table.to_md
# => "| Name  | Age | City     |\n| ----- | --- | -------- |\n| Alice | 30  | New York |\n| Bob   | 25  | London   |"
```

#### `to_csv`

Converts the table to a CSV-formatted string.

**Returns:** String containing CSV data

**Example:**
```ruby
table.to_csv
# => "Name,Age,City\nAlice,30,\"New York\"\nBob,25,London\n"
```

#### `to_html`

Converts the table to an HTML string.

**Returns:** String containing HTML table

**Example:**
```ruby
table.to_html
# Returns HTML table representation
```

## Marktable::Row Class

The `Row` class represents a single row in a table.

### Instance Methods

#### `[](key)`

Gets the value in the specified column.

**Parameters:**
- `key` (String, Integer): The column name (if table has headers) or index (if no headers)

**Returns:** The value at the specified column or nil if not found

#### `[]=(key, value)`

Sets the value in the specified column.

**Parameters:**
- `key` (String, Integer): The column name (if table has headers) or index (if no headers)
- `value`: The value to set

**Returns:** The value that was set

#### `values`

Gets all values in the row.

**Returns:** Array of values

#### `to_h`

Converts the row to a hash.

**Returns:** Hash where keys are header values and values are cell values

## RSpec Matchers

### `match_markdown`

Compares tables across different formats.

**Example:**
```ruby
# Compare two markdown tables
expect(markdown_table1).to match_markdown(markdown_table2)

# Compare array with markdown
expect(array_data).to match_markdown(markdown_table).with_format(:array)

# Compare HTML with markdown
expect(html_table).to match_markdown(markdown_table).with_format(:html)

# Compare CSV with markdown
expect(csv_data).to match_markdown(markdown_table).with_format(:csv)
```

#### Method Chaining

##### `with_format(format)`

Specifies the format of the actual value. Necessary to specify the format of String expected values.

**Parameters:**
- `format` (Symbol): One of `:markdown`, `:csv`, or `:html`

**Note** In case of Array, CSV::Table and Nokogiry node, calling `with_format` is not necessary. 

**Example:**
```ruby
expect(csv_string).to match_markdown(markdown_table).with_format(:csv)
```

## Error Handling

The `Marktable::Table` class handles various error conditions:

1. **Duplicate Headers**: Raises `ArgumentError` if headers have duplicate values
   ```ruby
   # Raises: ArgumentError: Duplicate headers are not allowed: ["Name", "Name"]
   ```

2. **Invalid Input**: Raises `ArgumentError` if the input format is invalid
   ```ruby
   # Raises: ArgumentError: Cannot parse CSV from Integer
   ```

3. **Empty Input**: Creates an empty table without raising errors
   ```ruby
   table = Marktable::Table.new(nil)
   table.empty? # => true
   ```
