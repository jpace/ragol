#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/option'
require 'ragol/argslist'

module Ragol
  class Results
    include Logue::Loggable

    attr_reader :options
    
    def initialize options, args = Array.new
      @argslist = Ragol::ArgsList.new(args)
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

    def unprocessed
      @argslist
    end

    def end_of_options?
      @argslist.end_of_options?
    end

    def args
      @argslist.args
    end

    def next_arg
      @argslist.next_arg
    end

    def shift_arg
      @argslist.shift_arg
    end

    def args_empty?
      @argslist.args_empty?
    end

    def current_arg
      @argslist.current_arg
    end
  end
end
