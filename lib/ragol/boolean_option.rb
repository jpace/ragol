#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/option'

module Ragol
  # a boolean option maps to a single tag, not a tag and value. For example,
  # "-v" (verbose) is a boolean option, but "-r 3444" (revision) is a option
  # with a value.
  class BooleanOption < Option
    def takes_value?
      false
    end
  end
end
