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

    def initialize(name, tag, description, deflt, options = Hash.new, &blk)
      args = OptionArguments.new name, tag, description, deflt, options
      super args, &blk
    end

    def self.default
      nil
    end
  end
end
