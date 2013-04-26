#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/option'
require 'ragol/common/fixnum_option'

module Synoption
  # An option that has a fixnum (integer) as its value.
  class FixnumOption < Ragol::FixnumOption
    include Synoption::OptionInit

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
