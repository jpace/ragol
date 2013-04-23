#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/common/option'
require 'ragol/synoption/args'

module Synoption
  class Option < Ragol::Option
    def initialize name, tag, description, default, options = Hash.new
      args = OptionArguments.new name, tag, description, default, options
      super args
    end
  end
end
