#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/tag_option'

module OptProc
  class FloatOption < TagOption
    REGEXP = Regexp.new '^ ([\-\+]?\d* (?:\.\d+)?) $ ', Regexp::EXTENDED
    
    def value_regexp
      REGEXP
    end
    
    def convert_value val
      val.to_f
    end
  end
end
