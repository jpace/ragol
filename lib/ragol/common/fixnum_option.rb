#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/common/option'

module Ragol
  class FixnumOption < Option
    REGEXP = Regexp.new '^ ([\-\+]?\d+) $ ', Regexp::EXTENDED
    
    def value_regexp
      REGEXP
    end
    
    def convert md
      return unless val = md && md[-1]
      val.to_i
    end
  end
end
