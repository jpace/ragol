#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/option'

module Synoption
  # a boolean option maps to a single tag, not a tag and value. For example,
  # "-v" (verbose) is a boolean option, but "-r 3444" (revision) is a option
  # with a value.
  class BooleanOption < Option
    def initialize name, tag, description, deflt = false, options = Hash.new, &blk
      super
    end

    def default
      false
    end

    def takes_value?
      false
    end
  end
end
