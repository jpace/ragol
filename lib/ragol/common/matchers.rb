#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/common/tags'

module Ragol
  class Matchers
    include Logue::Loggable

    attr_reader :exact
    attr_reader :negative
    attr_reader :regexp

    def initialize tags, negate, regexp
      @exact = tags
      @negative = negate
      @regexp = regexp
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

    def match_type? arg
      case 
      when exact_match?(arg)
        :exact_match
      when negative_match?(arg)
        :negative_match
      when regexp_match?(arg)
        :regexp_match
      else
        nil
      end
    end
  end
end
