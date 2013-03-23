#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'

module OptProc
  class TagOption < Option
    def convert md
      return unless val = md && md[1]
      convert_value val
    end
  end
end
