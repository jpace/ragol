#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'ragol/synoption/doc'
require 'ragol/synoption/matchers'

module Synoption
  class Option
    include Logue::Loggable

    attr_reader :default
    attr_reader :description
    attr_reader :matchers

    def initialize name, tag, description, default, options = Hash.new
      @description = description
      @value = @default = default
      @matchers = Matchers.new tag, name, options[:negate], options[:regexp]
      @unsets = options[:unsets]
    end

    def tag
      @matchers.exact.tag
    end

    def name
      @matchers.exact.name
    end

    def takes_value?
      true
    end

    def exact_match? arg
      @matchers.exact_match? arg
    end

    def negative_match? arg
      @matchers.negative_match? arg
    end

    def regexp_match? arg
      @matchers.regexp_match? arg
    end

    def unset results
      debug "results: #{results}"
      @value = nil
    end

    def set_value results, val
      debug "results: #{results}"
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

    def process results, args
      if exact_match?(args[0])
        args.shift
        val = takes_value? ? next_argument(args) : true
        set_value results, val
        true
      elsif negative_match?(args[0])
        args.shift
        set_value results, false
        true
      elsif md = regexp_match?(args[0])
        args.shift
        set_value results, md[0]
        true
      else
        false
      end
    end

    def post_process option_set, results, unprocessed
      resolve_value option_set, results, unprocessed

      if @unsets
        option_set.unset results, @unsets
      end
    end

    def resolve_value option_set, results, unprocessed
    end
  end
end
