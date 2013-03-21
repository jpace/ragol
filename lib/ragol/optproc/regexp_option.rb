#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'
require 'ragol/optproc/regexps'

module OptProc
  class RegexpOption < Option
    attr_reader :regexps
    
    def initialize(*args, &blk)
      optargs = args[0]
      regexps = optargs[:regexps] || optargs[:regexp] || optargs[:res]
      @regexps = Regexps.new([ regexps ].flatten)
      super
    end

    def match_tag_score opt
      @regexps.match_tag_score opt
    end

    def take_value opt, args
      @regexps.match opt
    end
  end
end
