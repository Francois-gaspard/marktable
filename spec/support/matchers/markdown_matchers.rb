# frozen_string_literal: true

require 'capybara'
require 'nokogiri'
require_relative '../../../lib/marktable/matchers_core'

RSpec::Matchers.define :match_markdown do |expected_markdown|
  include Marktable::MatchersCore
  
  chain :with_format do |format|
    @format = format
  end

  match do |actual|
    @expected_data = parse_input(expected_markdown, :markdown)
    @format ||= infer_format(actual)
    @actual_data = parse_input(actual, @format)

    # Compare data using to_a for consistent comparison
    @actual_data.to_a == @expected_data.to_a
  end

  failure_message do
    format_failure_message(@expected_data, @actual_data)
  end

  failure_message_when_negated do
    format_negated_failure_message(@actual_data)
  end
end
