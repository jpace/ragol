#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/fixnum_option'
require 'ragol/synoption/option'

module Synoption
  # An option that has a fixnum (integer) as its value.
  class FixnumOption < Ragol::FixnumOption
    include Synoption::OptionInit
  end
end
