#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/common/tags'

module Synoption
  class Matchers
    include Logue::Loggable

    attr_reader :exact
    attr_reader :negative
    attr_reader :regexp

    def initialize tag, name, negate, regexp
      long_tag = '--' + name.to_s.gsub('_', '-')
      @exact = Ragol::Tags.new [ tag, long_tag ]
      @negative = negate && Ragol::Tags.new(negate)
      @regexp = regexp && Ragol::Tags.new([ regexp ])
    end

    def exact_match? arg
      @exact.match? arg
    end

    def negative_match? arg
      @negative and @negative.match? arg
    end

    def regexp_match? arg
      @regexp and @regexp.match? arg
    end
  end
end
