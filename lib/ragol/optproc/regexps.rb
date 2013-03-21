#!/usr/bin/ruby -w
# -*- ruby -*-

module OptProc
  class Regexps
    def initialize regexps
      @regexps = regexps
    end

    def match_tag_score opt
      return 1.0 if @regexps.find { |re| re.match(opt) }
    end

    def match opt
      @regexps.collect { |re| re.match(opt) }.detect { |x| x }
    end
  end
end
