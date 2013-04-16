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
    
    def initialize name, default, tags, negates, regexps, unsets, process, takesvalue
      @name = name
      @default = default

      tagsmatch = tags && Ragol::Matcher.new(tags)
      negatesmatch = negates && Ragol::Matcher.new(negates)
      regexpsmatch = regexps && Ragol::Matcher.new(regexps)

      @matchers = Ragol::Matchers.new tagsmatch, negatesmatch, regexpsmatch
      @unsets = unsets
      @process = process
      @takesvalue = takesvalue
    end

    def takes_value?
      @takesvalue
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
      md.kind_of?(MatchData) ? md[-1] : md
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

    def take_eq_value opt
      val = opt.split('=', 2)[1]
      val && do_match(val)
    end

    def argument_missing
      if takes_value? == true
        raise "value expected for option: #{self}"
      end
    end

    def match_next_value results
      if takes_value? == true
        val = results.shift_arg
        val && do_match(val)
      elsif val = results.current_arg
        if val[0] == '-'
          true
        else
          results.shift_arg
          do_match(val)
        end
      else
        nil
      end
    end

    def set_value_for_tag results, arg
      md = if takes_value?
             take_eq_value(arg) || match_next_value(results) || argument_missing
           else
             true
           end
      set_option_value md, arg, results
    end

    def set_value_negative results, arg
      set_option_value false, arg, results
    end

    def set_value_regexp results, arg
      md = @matchers.regexp_match? arg
      set_option_value md, arg, results
    end

    def set_option_value md, arg, results
      value = md == true ? true : convert(md)
      if @process
        setargs = [ value, arg, results.unprocessed ][0 ... @process.arity]
        @process.call(*setargs)
      end
      results.set_value name, value
    end
  end
end
