#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/common/matcher'

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
      @tags and @tags.match? arg
    end

    def negative_match? arg
      @negatives and @negatives.match? arg
    end

    def regexp_match? arg
      @regexps and @regexps.match? arg
    end

    def match_type? arg
      case 
      when tm = tag_match?(arg)
        [ :tag_match, tm ]
      when nm = negative_match?(arg)
        [ :negative_match, nm ]
      when rm = regexp_match?(arg)
        [ :regexp_match, rm ]
      else
        nil
      end
    end

    def name
      @name ||= begin
                  if @tags
                    if longtag = @tags.elements.find { |t| t[0, 2] == '--' }
                      longtag.sub(%r{^--}, '')
                    else
                      @tags[0][1 .. -1]
                    end
                  elsif @regexps
                    @regexps.elements[0].to_s
                  end
                end
    end

    def to_s
      str = ""
      str << @tags.to_s if @tags
      str << @regexps.to_s if @regexps
      str
    end
  end
end
