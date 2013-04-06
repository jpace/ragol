#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/tag_option'

module OptProc
  class BooleanOption < TagOption
    def value_regexp
      nil
    end
  end
end
