#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/option'

module Synoption
  # An option that has a float as its value.
  class FloatOption < Option
    def convert val
      super val.to_f
    end
  end
end
