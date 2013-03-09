#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'ragol/synoption/match'

module Synoption
  class Matchers
    include Logue::Loggable

    attr_reader :exact
    attr_reader :negative
    attr_reader :regexp

    def initialize tag, name, negate, regexp
      @exact = OptionExactMatch.new tag, name
      @negative = negate && OptionNegativeMatch.new(negate)
      @regexp = regexp && OptionRegexpMatch.new(regexp)
    end
  end
end
