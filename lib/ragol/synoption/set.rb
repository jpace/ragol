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

      cls = self.class
      while cls <= OptionSet
        opts = self.class.options_for_class(cls)
        
        opts.each do |option|
          args = option[:args]
          opt = option[:class].new(*args)
          
          add opt
        end
        
        cls = cls.superclass
      end
    end

    def name
      @name ||= self.class.to_s.sub(%r{.*?(\w+)OptionSet}, '\1').downcase
    end
  end
end
