#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'ragol/synoption/option'
require 'ragol/synoption/builder'

module Synoption
  class Results
    include Logue::Loggable

    attr_reader :options
    attr_accessor :unprocessed
    
    def initialize cls, args = Array.new
      @unprocessed = args
      @values = Hash.new

      if cls
        options = Builder.all_options_for_set cls
        info "options: #{options}"
        options.each do |opt|
          @values[opt[:name]] = nil

          self.class.define_method opt[:name] do
            instance_eval do
              @values[opt[:name]]
            end
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
