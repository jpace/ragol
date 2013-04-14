#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/option'

module Synoption
  # An option that has a fixnum (integer) as its value.
  class FixnumOption < Option
    def convert_value val
      val.to_i
    end

    def set_option_value val, results
      super val && val.to_i, results
    end
  end
end
