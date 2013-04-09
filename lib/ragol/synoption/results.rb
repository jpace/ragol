#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'ragol/synoption/option'
require 'ragol/common/argslist'

module Synoption
  class Results
    include Logue::Loggable

    attr_reader :options
    attr_accessor :unprocessed
    
    def initialize options, args = Array.new
      @unprocessed = Ragol::ArgsList.new(args)
      @values = Hash.new

      options.each do |option|
        @values[option.name] = option.default
        
        singleton_class.define_method option.name do
          instance_eval do
            @values[option.name]
          end
        end
      end
    end

    def value optname
      @values[optname]
    end

    def set_value optname, value
      @values[optname] = value
    end

    def unset_value optname
      @values.delete optname
    end

    def end_of_options?
      current_arg == '--'
    end

    def args
      @unprocessed.args
    end

    def next_arg
      @unprocessed.next_arg
    end

    def args_empty?
      @unprocessed.args_empty?
    end

    def current_arg
      @unprocessed.current_arg
    end
  end
end
