#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'

module OptProc
  class TagOption < Option
    # converts from metadata, from matching the value.
    def convert md
      return unless val = md && md[-1]
      convert_value val
    end
  end
end
