#!/usr/bin/ruby -w
# -*- ruby -*-

module Ragol
  class Regexps
    def initialize regexps
      @regexps = regexps
    end

    def score opt
      match?(opt) && 1.0
    end

    def match? opt
      @regexps.collect { |re| re.match(opt) }.detect { |x| x }
    end

    def to_s
      @regexps.to_s
    end
  end
end
