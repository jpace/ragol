#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/float_option'
require 'ragol/synoption/option'

module Synoption
  # An option that has a float as its value.
  class FloatOption < Ragol::FloatOption
    include OptionInit
  end
end
