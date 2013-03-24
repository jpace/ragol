#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'

module Synoption
  class OptionMatch
    include Logue::Loggable

    def match? arg
      raise "not implemented"
    end
  end

  class OptionExactMatch < OptionMatch
    def initialize tag, name
      @tag = tag
      @name = name.to_s.gsub('_', '-')
    end

    def match? arg
      arg == @tag || arg == '--' + @name
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

  class OptionRegexpMatch < OptionMatch
    def initialize regexp
      @regexp = regexp
    end

    def match? arg
      arg && @regexp.match(arg)
    end
  end
end
