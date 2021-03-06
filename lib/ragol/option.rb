#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/matcher'
require 'ragol/matchers'
require 'ragol/doc'

module Ragol
  class Option
    include Logue::Loggable

    attr_reader :matchers

    attr_accessor :name
    attr_accessor :default
    attr_accessor :description
    attr_accessor :tags
    attr_accessor :negates
    attr_accessor :regexps
    
    def initialize options = Hash.new, &blk
      @tags = nil
      @negates = nil
      @regexps = nil
      @name = nil
      @default = nil
      @unsets = nil
      @process = nil
      @takesvalue = nil
      @rcnames = nil
      @description = nil

      if blk
        blk.call self
      end

      tagsmatch = to_matcher(@tags || options[:tags])
      negatesmatch = to_matcher(@negates || options[:negates])
      regexpsmatch = to_matcher(@regexps || options[:regexps])

      @matchers = Ragol::Matchers.new tagsmatch, negatesmatch, regexpsmatch

      @name ||= options[:name] || @matchers.name

      @default ||= options[:default]
      @unsets ||= options[:unsets]
      @process ||= options[:process]
      @takesvalue ||= options[:takesvalue]
      @rcnames ||= [ options[:rcnames] ].flatten
      @description ||= options[:description]
    end

    def match_rc? field
      @rcnames.include?(field)
    end

    def to_matcher elements
      elements && Ragol::Matcher.new(elements)
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
      if valuere = value_regexp
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

    def match_next_value_required results
      val = results.shift_arg
      val && do_match(val)
    end

    def match_next_value_optional results
      return unless val = results.current_arg
      return true if val[0] == '-'
      return results.shift_arg unless valuere = value_regexp
      
      if md = valuere.match(results.current_arg)
        results.shift_arg
        md
      else
        true
      end
    end

    def match_next_value results
      if takes_value? == true
        match_next_value_required results
      else
        match_next_value_optional results
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
      
    def to_doc io
      doc = Ragol::Doc.new self
      doc.to_doc io
    end
  end
end
