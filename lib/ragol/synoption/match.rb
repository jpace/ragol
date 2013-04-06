#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'ragol/common/tags'
require 'ragol/common/regexps'

module Synoption
  class OptionNegativeMatch < Ragol::Tags
    attr_reader :negopts

    def initialize(*negopts)
      args = Array.new(negopts).flatten
      super args
      @negopts = args
    end
  end

  class OptionRegexpMatch < Ragol::Regexps
    def initialize regexp
      super [ regexp ]
    end
  end
end
