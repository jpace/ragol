#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/option'

module Synoption
  # An option that has a float as its value.
  class FloatOption < Option
    def set_option_value val, results
      super val && val.to_f, results
    end
  end
end
