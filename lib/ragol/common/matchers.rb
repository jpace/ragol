#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/common/tags'

module Ragol
  class Matchers
    include Logue::Loggable

    attr_reader :tags
    attr_reader :negatives
    attr_reader :regexps

    def initialize tags, negate, regexp
      @tags = tags
      @negatives = negate
      @regexps = regexp
    end

    def tag_match? arg
      @tags.match? arg
    end

    def negative_match? arg
      @negatives and @negatives.match? arg
    end

    def regexp_match? arg
      @regexps and @regexps.match? arg
    end

    def match_score arg
      (@regexps && @regexps.score(arg)) || (@tags && @tags.score(arg))
    end

    def match_type? arg
      case 
      when tag_match?(arg)
        :tag_match
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
