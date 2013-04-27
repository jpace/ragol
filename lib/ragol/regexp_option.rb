#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/option'

module Ragol
  class RegexpOption < Option
    def initialize args
      @regexp = args[:valueregexp]
      super
    end
    
    def value_regexp
      @regexp
    end
  end
end
