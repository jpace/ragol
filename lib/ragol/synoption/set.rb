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
      while cls
        add_options_for_class cls
        cls = cls.superclass
        break unless cls <= OptionSet
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

    def match_type opt, arg
      opt.matchers.match_type? arg
    end

    def get_best_match args
      match_types = options.collect do |opt|
        [ match_type(opt, args[0]), opt ]
      end

      [ :tag_match, :negative_match, :regexp_match ].each do |type|
        if m = match_types.assoc(type)
          return m
        end
      end

      nil
    end

    def process args
      debug "args: #{args}"
      results = Results.new options, args
      
      options_processed = Array.new

      debug "args: #{args.inspect}"
      debug "results.unprocessed: #{results.unprocessed.inspect}"

      aborted = false
      
      while !results.unprocessed.empty?
        if results.end_of_options?
          results.unprocessed.shift
          aborted = true
          break
        elsif results.unprocessed[0][0] != '-'
          break
        end

        if opt = set_option(results)
          options_processed << opt
        else
          break
        end
      end

      unless aborted
        check_for_valid_options results
      end

      post_process_all results, options_processed

      results
    end

    def set_option results
      type, opt = get_best_match(results.unprocessed)

      return unless type

      case type
      when :tag_match
        results.unprocessed.shift
        opt.set_value_for_tag results, results.unprocessed
      when :negative_match
        results.unprocessed.shift
        opt.set_value_negative results
      when :regexp_match
        arg = results.unprocessed.shift
        opt.set_value_regexp results, arg
      end

      opt
    end

    def check_for_valid_options results
      results.unprocessed.each do |opt|
        if opt.start_with? '-'
          raise OptionException.new "option '#{opt}' invalid for #{name}"
        end
      end
    end

    def post_process_all results, options_processed
      options_processed.each do |opt|
        opt.post_process self, results, results.unprocessed
      end
    end
  end
end
