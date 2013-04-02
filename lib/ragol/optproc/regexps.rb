#!/usr/bin/ruby -w
# -*- ruby -*-

module OptProc
  class Regexps
    def initialize regexps
      @regexps = regexps
    end

    def score opt
      @regexps.find { |re| re.match(opt) } && 1.0
    end

    def match opt
      @regexps.collect { |re| re.match(opt) }.detect { |x| x }
    end

    def to_s
      @regexps.to_s
    end
  end
end
