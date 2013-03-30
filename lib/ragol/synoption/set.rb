#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'ragol/synoption/option'
require 'ragol/synoption/exception'
require 'ragol/synoption/list'
require 'ragol/synoption/builder'
require 'ragol/synoption/results'

module Synoption
  class OptionSet < OptionList
    include Logue::Loggable

    def self.has_option name, optcls, optargs = Hash.new
      Builder.add_has_option self, name, optcls, optargs
    end
    
    def initialize options = Array.new
      super

      options.each do |option|
        instance_variable_set '@' + option.name.to_s, option
        singleton_class.define_method option.name do
          instance_eval do
            opt = instance_variable_get '@' + option.name.to_s
            opt.value
          end
        end
      end
      
      add_all_options
    end

    def add_all_options
      cls = self.class
      while cls != OptionSet
        add_options_for_class cls
        cls = cls.superclass
      end
    end
    
    def add_options_for_class cls
      opts = Builder.options_for_class(cls)

      opts.each do |option|
        add_option option
      end
    end

    def add_option option
      name = option[:name]
      cls = option[:class]
      args = option[:args]
      opt = cls.new(*args)
      debug "opt: #{opt}"
      
      add opt
      instance_variable_set '@' + name.to_s, opt

      singleton_class.define_method name do
        instance_eval do
          opt = instance_variable_get '@' + name.to_s
          opt.value
        end
      end
    end
    
    def unset results, key
      if opt = find_by_name(key)
        opt.unset(results)
        results.unset_value opt.name
      end
    end

    def process args
      debug "args: #{args}"
      results = Results.new options, args
      
      options_processed = Array.new

      debug "args: #{args.inspect}"
      debug "results.unprocessed: #{results.unprocessed.inspect}"

      aborted = false
      
      while !results.unprocessed.empty?
        if results.unprocessed[0] == '--'
          results.unprocessed.delete_at 0
          aborted = true
          break
        end

        processed = false

        options.each do |opt|
          if opt.process results, results.unprocessed
            debug "opt: #{opt.inspect}"
            processed = true
            options_processed << opt
          end
        end

        break unless processed
      end

      unless aborted
        check_for_valid_options results
      end

      post_process_all results, options_processed

      results
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
