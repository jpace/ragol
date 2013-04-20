#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'

module OptProc
  class StringOption < Option
    REGEXP = Regexp.new '^ [\"\']? (.*?) [\"\']? $ ', Regexp::EXTENDED
    
    def value_regexp
      REGEXP
    end
  end
end
