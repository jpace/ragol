#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'ragol/synoption/option'
require 'ragol/synoption/exception'
require 'ragol/synoption/list'
require 'ragol/synoption/results'

module Synoption
  class OptionSet < OptionList
    include Logue::Loggable

    # maps from an OptionSet class to the valid options for that class.
    @@options_for_class = Hash.new { |h, k| h[k] = Array.new }

    def self.has_option name, optcls, optargs = Hash.new
      @@options_for_class[self] << { :name => name, :class => optcls, :args => optargs }
    end

    def self.options_for_class cls
      @@options_for_class[cls]
    end
    
    def initialize(*options)
      super
      add_all_options
    end

    def add_all_options
      cls = self.class
      while cls <= OptionSet
        add_options_for_class cls
        cls = cls.superclass
      end
    end
    
    def add_options_for_class cls
      opts = self.class.options_for_class(cls)

      opts.each do |option|
        add_option option
      end
    end

    def add_option option
      name = option[:name]
      cls = option[:class]
      args = option[:args]
      opt = cls.new(*args)
      
      add opt
    end
    
    def unset results, key
      if opt = find_by_name(key)
        opt.unset(results)
        results.unset_value opt.name
      end
    end

    def get_best_match results
      arg = results.current_arg

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
          raise "ambiguous match of '#{arg}'; matches options: #{optstr}"
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

    def process args
      results = Results.new options, args      
      options_processed = Array.new
      
      while !results.args_empty?
        if results.end_of_options?
          results.shift_arg
          break
        elsif results.current_arg[0] != '-'
          break
        end

        opt = set_option(results)
        options_processed << opt
      end

      options_processed.each do |opt|
        opt.post_process self, results, results.args
      end

      results
    end

    def set_option results
      type, opt = get_best_match(results)
      
      unless type
        raise OptionException.new "option '#{results.current_arg}' invalid for #{name}"
      end

      case type
      when :tag_match
        results.next_arg
        opt.set_value_for_tag results
      when :negative_match
        results.next_arg
        opt.set_value_negative results
      when :regexp_match
        arg = results.next_arg
        opt.set_value_regexp results, arg
      end

      opt
    end
  end
end
