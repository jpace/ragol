#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/synoption/doc'
require 'ragol/common/matchers'
require 'ragol/common/tags'

module Synoption
  class Option
    include Logue::Loggable

    attr_reader :default
    attr_reader :description
    attr_reader :matchers
    attr_reader :name
    attr_reader :tag

    def initialize name, tag, description, default, options = Hash.new
      @name = name
      @tag = tag
      @description = description
      @value = @default = default

      tags = Ragol::Tags.new [ tag, '--' + name.to_s.gsub('_', '-') ]
      negates = options[:negate] && Ragol::Tags.new(options[:negate])
      regexps = options[:regexp] && Ragol::Tags.new(options[:regexp])

      @matchers = Ragol::Matchers.new tags, negates, regexps
      @unsets = options[:unsets]
    end

    def takes_value?
      true
    end

    def set_value results, val
      results.set_value name, val
    end
      
    def to_doc io
      doc = Doc.new self
      doc.to_doc io
    end

    def next_argument results
      raise "option #{name} expects following argument" if results.args_empty?
      results.shift_arg
    end

    def set_value_for_tag results, arg
      val = takes_value? ? next_argument(results) : true
      set_value results, val
    end

    def set_value_negative results, arg
      set_value results, false
    end

    def set_value_regexp results, arg
      md = @matchers.regexp_match? arg
      set_value results, md[0]
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
  end
end
