# frozen_string_literal: true

require 'spec_helper'

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
      { "Name" => "John", "Age" => "30" },
      { "Name" => "Jane", "Age" => "25" }
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
      expect(array_of_hashes).to match_markdown(markdown_table)
    end

    it 'fails when the array does not match the table' do
      different_array = [
        { "Name" => "John", "Age" => "31" },
        { "Name" => "Jane", "Age" => "25" }
      ]
      expect(different_array).not_to match_markdown(markdown_table)
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
