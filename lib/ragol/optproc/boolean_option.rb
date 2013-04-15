#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'

module OptProc
  class BooleanOption < Option
    def value_regexp
      nil
    end
  end
end
