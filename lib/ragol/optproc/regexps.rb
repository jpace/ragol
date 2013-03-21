#!/usr/bin/ruby -w
# -*- ruby -*-

module OptProc
  class Regexps
    def initialize regexps
      @regexps = regexps
    end

    def match_tag_score opt
      @regexps.find { |re| re.match(opt) } && 1.0
    end

    def match opt
      @regexps.collect { |re| re.match(opt) }.detect { |x| x }
    end
  end
end
