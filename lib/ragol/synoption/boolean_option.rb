#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/option'
require 'ragol/common/boolean_option'

module Synoption
  # a boolean option maps to a single tag, not a tag and value. For example,
  # "-v" (verbose) is a boolean option, but "-r 3444" (revision) is a option
  # with a value.
  class BooleanOption < Ragol::Option
    include OptionInit
    
    def default_value
      false
    end

    def takes_value?
      false
    end
  end
end
