#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'ragol/synoption/option'
require 'ragol/synoption/exception'
require 'ragol/synoption/list'
require 'ragol/synoption/builder'

module Synoption
  class OptionSet < OptionList
    include Logue::Loggable

    attr_reader :unprocessed

    def self.has_option name, optcls, optargs = Hash.new
      Builder.add_has_option self, name, optcls, optargs
    end

    attr_reader :options
    
    def initialize options = Array.new
      super 

      cls = self.class
      while cls != OptionSet
        add_options_for_class cls
        cls = cls.superclass
      end
    end
    
    def add_options_for_class cls
      opts = Builder.options_for_class(cls)

      opts.each do |option|
        name = option[:name]
        cls = option[:class]
        args = option[:args]
        opt = cls.new(*args)
        
        add opt
        instance_variable_set '@' + name.to_s, opt
      end
    end

    def unset key
      opt = find_by_name key
      opt && opt.unset
    end

    def process args
      options_processed = Array.new

      debug "args: #{args.inspect}"
      @unprocessed = args
      debug "@unprocessed: #{@unprocessed.inspect}"

      aborted = false
      
      while !@unprocessed.empty?
        if @unprocessed[0] == '--'
          @unprocessed.delete_at 0
          aborted = true
          break
        end

        processed = false

        options.each do |opt|
          if opt.process @unprocessed
            debug "opt: #{opt.inspect}"
            processed = true
            options_processed << opt
          end
        end

        break unless processed
      end

      unless aborted
        check_for_valid_options 
      end

      post_process_all options_processed
    end

    def check_for_valid_options 
      @unprocessed.each do |opt|
        if opt.start_with? '-'
          raise OptionException.new "error: option: #{opt} invalid for #{name}"
        end
      end
    end

    def post_process_all options_processed
      options_processed.each do |opt|
        opt.post_process self, @unprocessed
      end
    end
  end
end
