#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/option'
require 'ragol/common/option_set'

module Synoption
  class OptionSet < Ragol::OptionSet
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

    def name
      @name ||= self.class.to_s.sub(%r{.*?(\w+)OptionSet}, '\1').downcase
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
  end
end
