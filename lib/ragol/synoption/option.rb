#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/common/option'
require 'ragol/synoption/args'

module Synoption
  module OptionInit
    def initialize(*args, &blk)
      name, tag, description, deflt, options = *args
      options ||= Hash.new
      deflt ||= default_value
      args = OptionArguments.new name, tag, description, deflt, options
      super args, &blk
    end

    def default_value
      nil
    end
  end
end

module Synoption
  class Option < Ragol::Option
    include OptionInit
  end
end
