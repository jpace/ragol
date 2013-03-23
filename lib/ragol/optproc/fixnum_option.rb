#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/tag_option'

module OptProc
  class FixnumOption < TagOption
    REGEXP = Regexp.new '^ ([\-\+]?\d+) $ ', Regexp::EXTENDED
    
    def value_regexp
      REGEXP
    end
    
    def convert_value val
      val.to_i
    end
  end
end
