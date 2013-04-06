#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'ragol/common/tags'
require 'ragol/common/regexps'

module Synoption
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

  class OptionNegativeMatch < Ragol::Tags
    attr_reader :negopts

    def initialize(*negopts)
      super Array.new(negopts).flatten
      # in case this gets passed an array as an element:
      @negopts = Array.new(negopts).flatten
    end
  end

  class OptionRegexpMatch < Ragol::Regexps
    def initialize regexp
      super [ regexp ]
    end
  end
end
