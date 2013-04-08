#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/option'

module Synoption
  # An option that has a float as its value.
  class FloatOption < Option
    def set_value results, val
      super results, val && val.to_f
    end
  end
end
