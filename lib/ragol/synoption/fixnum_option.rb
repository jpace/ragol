#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/option'
require 'ragol/common/fixnum_option'

module Synoption
  # An option that has a fixnum (integer) as its value.
  class FixnumOption < Ragol::FixnumOption
    include Synoption::OptionInit
  end
end
