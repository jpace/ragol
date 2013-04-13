#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/synoption/option'
require 'ragol/common/exception'
require 'ragol/common/results'
require 'ragol/common/option_set'

module Synoption
  class OptionSet < Ragol::OptionSet
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

    def name
      @name ||= self.class.to_s.sub(%r{.*?(\w+)OptionSet}, '\1')
      puts @name
      @name
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
    
    def unset results, key
      if opt = find_by_name(key)
        results.unset_value opt.name
      end
    end

    def process args
      results = Ragol::Results.new options, args
      options_processed = Array.new
      
      while !results.args_empty?
        if results.end_of_options?
          results.shift_arg
          break
        elsif results.current_arg[0] != '-'
          break
        end

        opt = set_option(results)
        options_processed << opt
      end

      options_processed.each do |opt|
        opt.post_process self, results, results.args
      end

      results
    end

    def find_matching_option results
      type, opt = get_best_match(results)
      
      unless type
        raise Ragol::OptionException.new "#{name}: invalid option '#{results.current_arg}'"
      end

      [ type, opt ]
    end

    def set_option results
      type, opt = find_matching_option(results)

      case type
      when :tag_match
        results.next_arg
        opt.set_value_for_tag results
      when :negative_match
        results.next_arg
        opt.set_value_negative results
      when :regexp_match
        arg = results.next_arg
        opt.set_value_regexp results, arg
      end

      opt
    end
  end
end
