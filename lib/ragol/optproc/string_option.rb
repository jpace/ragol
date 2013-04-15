#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'

module OptProc
  class StringOption < Option
    REGEXP = Regexp.new '^ [\"\']? (.*?) [\"\']? $ ', Regexp::EXTENDED
    
    def value_regexp
      REGEXP
    end
    
    def convert md
      return unless val = md && md[-1]
      val
    end
  end
end
