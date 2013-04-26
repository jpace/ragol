#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/common/float_option'
require 'ragol/synoption/option'

module Synoption
  # An option that has a float as its value.
  class FloatOption < Ragol::FloatOption
    include OptionInit
    
    REGEXP = Regexp.new '^ ([\-\+]?\d* (?:\.\d+)?) $ ', Regexp::EXTENDED
    
    def value_regexp
      REGEXP
    end

    def convert md
      return unless val = md && md[-1]
      val.to_f
    end
  end
end
