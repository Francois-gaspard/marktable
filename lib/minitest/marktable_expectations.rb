# frozen_string_literal: true

require 'minitest/expectations'
require 'minitest/assertions'
require 'marktable'
require_relative 'marktable_assertions'

module Minitest
  # Support for markdown table expectations in Minitest
  module MarktableSupport
    # Store format information for use in expectations
    class FormatInfo
      @formats = {}
      
      class << self
        attr_reader :formats
        
        def set_format(object_id, format)
          @formats[object_id] = format
        end
        
        def get_format(object_id)
          @formats.delete(object_id)
        end
      end
    end
  end
  
  # Add the expectations that can be chained
  module Expectations
    # Add format specification option to any object
    def with_format(format)
      MarktableSupport::FormatInfo.set_format(self.object_id, format)
      self
    end
  end
end

# Make sure Minitest::Test includes MarktableAssertions to make assertions available
module Minitest
  class Test
    include MarktableAssertions
  end
end

# Infect the assertions into expectations
module Minitest
  Expectations.infect_an_assertion :assert_markdown_match, :must_match_markdown
  Expectations.infect_an_assertion :refute_markdown_match, :wont_match_markdown
end
