#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/option'

module Synoption
  # An option that has a float as its value.
  class FloatOption < Option
    REGEXP = Regexp.new '^ ([\-\+]?\d* (?:\.\d+)?) $ ', Regexp::EXTENDED
    
    def value_regexp
      REGEXP
    end

    def convert md
      md[-1].to_f
    end
  end
end
