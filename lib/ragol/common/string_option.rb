#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/common/option'

module Ragol
  class StringOption < Option
    REGEXP = Regexp.new '^ [\"\']? (.*?) [\"\']? $ ', Regexp::EXTENDED
    
    def value_regexp
      REGEXP
    end
  end
end
