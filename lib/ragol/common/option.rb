#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'

module Ragol
  class Option
    include Logue::Loggable

    attr_reader :name
    attr_reader :default
    
    def initialize name, default
      @name = name
      @default = default
    end
  end
end
