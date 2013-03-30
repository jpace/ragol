#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'ragol/synoption/option'

module Synoption
  class Results
    include Logue::Loggable

    attr_reader :options
    attr_accessor :unprocessed
    
    def initialize options, args = Array.new
      @unprocessed = args
      @values = Hash.new

      options.each do |option|
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
      @values.delete(optname)
    end
  end
end