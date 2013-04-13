#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/common/results'
require 'ragol/common/exception'

module Ragol
  class OptionSet
    include Logue::Loggable

    attr_reader :options

    def initialize(*options)
      @options = options
    end

    def inspect
      @options.collect { |opt| opt.inspect }.join("\n")
    end

    def find_by_name name
      @options.find { |opt| opt.name == name }
    end

    def << option
      add option
    end

    def add option
      @options << option
      option
    end
    
    def get_best_match results
      tag_matches = Hash.new { |h, k| h[k] = Array.new }
      negative_match = nil
      regexp_match = nil
      
      match_types = Hash.new
      options.each do |opt|
        if mt = opt.matchers.match_type?(results.current_arg)
          case mt[0]
          when :tag_match
            tag_matches[mt[1]] << opt
          when :negative_match
            negative_match = opt
          when :regexp_match
            regexp_match = opt
          end
        end
      end

      if tag_matches.keys.any?
        highest = tag_matches.keys.sort[-1]
        opts = tag_matches[highest]
        if opts.size > 1
          optstr = opts.collect { |opt| '(' + opt.to_s + ')' }.join(', ')
          raise "ambiguous match of '#{results.current_arg}'; matches options: #{optstr}"
        end
        [ :tag_match, opts.first ]
      elsif negative_match
        [ :negative_match, negative_match ]
      elsif regexp_match
        [ :regexp_match, regexp_match ]
      else
        nil
      end
    end

    def find_matching_option results
      type, opt = get_best_match(results)
      
      unless type
        raise OptionException.new "#{name}: invalid option '#{results.current_arg}'"
      end

      [ type, opt ]
    end
  end
end