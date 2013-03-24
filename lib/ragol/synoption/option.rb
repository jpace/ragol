#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'ragol/synoption/doc'
require 'ragol/synoption/match'
require 'ragol/synoption/matchers'

module Synoption
  class Option
    include Logue::Loggable

    attr_reader :name
    attr_reader :tag
    attr_reader :description
    attr_reader :default

    attr_reader :matchers

    def initialize name, tag, description, default, options = Hash.new
      @name = name
      @tag = tag
      @description = description

      @value = @default = default

      @matchers = Matchers.new @tag, @name, options[:negate], options[:regexp]
      
      @unsets = options[:unsets]
    end

    def takes_value?
      true
    end

    def to_s
      [ @name, @tag ].join(", ")
    end

    def exact_match? arg
      @matchers.exact.match? arg
    end

    def negative_match? arg
      @matchers.negative and @matchers.negative.match? arg
    end

    def regexp_match? arg
      @matchers.regexp and @matchers.regexp.match? arg
    end

    def unset
      @value = nil
    end

    def set_value val
      @value = val
    end

    def value
      @value
    end
      
    def to_doc io
      doc = Doc.new self
      doc.to_doc io
    end

    def next_argument args
      raise "option #{name} expects following argument" if args.empty?
      args.shift
    end

    def process args
      if @matchers.exact.match? args[0]
        args.shift
        val = takes_value? ? next_argument(args) : true
        set_value val
        true
      elsif @matchers.negative && @matchers.negative.match?(args[0])
        arg = args.shift
        set_value false
        true
      elsif @matchers.regexp && (md = @matchers.regexp.match?(args[0]))
        arg = args.shift
        set_value md[0]
        true
      else
        false
      end
    end

    def post_process option_set, unprocessed
      resolve_value option_set, unprocessed

      if @unsets
        option_set.unset @unsets
      end
    end

    def resolve_value option_set, unprocessed
    end
  end
end
