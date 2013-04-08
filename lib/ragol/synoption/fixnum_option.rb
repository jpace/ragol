#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/option'

module Synoption
  # An option that has a fixnum (integer) as its value.
  class FixnumOption < Option
    def set_value results, val
      super results, val && val.to_i
    end
  end
end
