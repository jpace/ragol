#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'

module OptProc
  class RegexpOption < Option
    def value_regexp
      nil
    end
    
    # returns the metadata, from matching the option.
    def convert md
      md
    end
  end
end
