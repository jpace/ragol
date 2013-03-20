#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/optproc/option'

module OptProc
  class RegexpOption < Option
    attr_reader :regexps
    
    def initialize args = Hash.new, &blk
      @regexps = args[:regexps] || args[:regexp] || args[:res]
      @regexps = [ @regexps ].flatten
      super
    end

    def match_tag_score opt
      return 1.0 if @regexps.find { |re| re.match(opt) }
    end

    def take_value opt, args
      @regexps.collect { |re| re.match(opt) }.detect { |x| x }
    end
  end
end
