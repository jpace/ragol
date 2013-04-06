#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'ragol/common/tags'
require 'ragol/common/regexps'

module Synoption
  class OptionMatch
    include Logue::Loggable

    def match? arg
      raise "not implemented"
    end
  end

  class OptionExactMatch < Ragol::Tags
    attr_reader :tag
    attr_reader :name
    
    def initialize tag, name
      @tag = tag
      @name = name
      long_tag = '--' + name.to_s.gsub('_', '-')

      super [ tag, long_tag ]
    end
  end

  class OptionNegativeMatch < OptionMatch
    attr_reader :negopts

    def initialize *negopts
      # in case this gets passed an array as an element:
      @negopts = Array.new(negopts).flatten
    end

    def match? arg
      arg && @negopts.select { |x| arg.index x }.size > 0
    end
  end

  class OptionRegexpMatch < Ragol::Regexps
    def initialize regexp
      super [ regexp ]
    end
  end
end
