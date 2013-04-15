#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'

module OptProc
  class FloatOption < Option
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
