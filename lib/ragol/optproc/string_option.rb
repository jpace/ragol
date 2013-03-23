#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/tag_option'

module OptProc
  class StringOption < TagOption
    REGEXP = Regexp.new '^ [\"\']? (.*?) [\"\']? $ ', Regexp::EXTENDED
    
    def value_regexp
      REGEXP
    end
    
    def convert_value val
      val
    end
  end
end
