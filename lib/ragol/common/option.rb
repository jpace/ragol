#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/common/matcher'
require 'ragol/common/matchers'

module Ragol
  class Option
    include Logue::Loggable

    attr_reader :name
    attr_reader :default
    attr_reader :matchers
    
    def initialize name, default, tags, negates, regexps, unsets
      @name = name
      @default = default

      tagsmatch = tags && Ragol::Matcher.new(tags)
      negatesmatch = negates && Ragol::Matcher.new(negates)
      regexpsmatch = regexps && Ragol::Matcher.new(regexps)

      @matchers = Ragol::Matchers.new tagsmatch, negatesmatch, regexpsmatch
      @unsets = unsets
    end

    def post_process option_set, results, unprocessed
      resolve_value option_set, results, unprocessed

      if @unsets
        option_set.unset results, @unsets
      end
    end

    def resolve_value option_set, results, unprocessed
    end
    
    def to_s
      @matchers.to_s
    end

    def value_regexp
    end

    def convert md
      md
    end

    def do_match val
      valuere = value_regexp
      if valuere
        unless md = valuere.match(val)
          raise "invalid argument '#{val}' for option: #{self}"
        end
        md
      else
        val
      end
    end
  end
end
