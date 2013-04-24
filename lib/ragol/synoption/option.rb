#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/common/option'
require 'ragol/synoption/args'

module Synoption
  class Option < Ragol::Option
    class << self
      alias_method :old_new, :new
      
      def new(*args, &blk)
        name, tag, description, default, options = *args
        old_new(*args, &blk)
      end
    end

    def initialize name, tag, description, default, options = Hash.new
      args = OptionArguments.new name, tag, description, default, options
      super args
    end
  end
end
