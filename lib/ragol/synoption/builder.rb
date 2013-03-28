#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'

module Synoption
  class Builder
    include Logue::Loggable

    # maps from an OptionSet class to the valid options for that class.
    @@options_for_class = Hash.new { |h, k| h[k] = Array.new }

    def self.add_has_option cls, name, optcls, optargs = Hash.new
      @@options_for_class[cls] << { :name => name, :class => optcls, :args => optargs }

      cls.define_method name do
        instance_eval do
          opt = instance_variable_get '@' + name.to_s          
          opt.value
        end
      end
    end

    def self.add_option_value_methods results, cls
      while cls != OptionSet
        @@options_for_class[cls].each do |opt|
          Logue::Log.info "opt: #{opt}"
          results.class.define_method opt[:name] do
            instance_eval do
              opt = instance_variable_get '@' + opt[:name].to_s
              opt.value
            end
          end
        end
        cls = cls.superclass
      end
    end
    
    def self.options_for_class cls
      @@options_for_class[cls]
    end
    
    def self.all_options_for_set setcls
      options = Array.new
      while setcls != OptionSet
        if opts = @@options_for_class[setcls]
          options.concat opts
        end
        setcls = setcls.superclass
      end
      options
    end
  end
end
