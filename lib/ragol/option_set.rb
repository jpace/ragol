#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/results'
require 'ragol/exception'

module Ragol
  class OptionSet
    include Logue::Loggable

    # maps from an OptionSet class to the valid options for that class.
    @@options_for_class = Hash.new { |h, k| h[k] = Array.new }

    def self.has_option name, optcls, optargs = Hash.new
      @@options_for_class[self] << { :name => name, :class => optcls, :args => optargs }
    end

    def self.options_for_class cls
      @@options_for_class[cls]
    end

    attr_reader :options
    
    def initialize(*options)
      @options = options

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

    def inspect
      @options.collect { |opt| opt.inspect }.join("\n")
    end

    def find_by_name name
      @options.find { |opt| opt.name == name }
    end

    def << option
      add option
    end

    def add option
      @options << option
      option
    end
    
    def get_best_match results
      tag_matches = Hash.new { |h, k| h[k] = Array.new }
      negative_match = nil
      regexp_match = nil

      options.each do |opt|
        if mt = opt.matchers.match_type?(results.current_arg)
          case mt[0]
          when :tag_match
            tag_matches[mt[1]] << opt
          when :negative_match
            negative_match = opt
          when :regexp_match
            regexp_match = opt
          end
        end
      end

      if tag_matches.keys.any?
        highest = tag_matches.keys.sort[-1]
        opts = tag_matches[highest]
        if opts.size > 1
          optstr = opts.collect { |opt| '(' + opt.to_s + ')' }.join(', ')
          raise "ambiguous match of '#{results.current_arg}'; matches options: #{optstr}"
        end
        [ :tag_match, opts.first ]
      elsif negative_match
        [ :negative_match, negative_match ]
      elsif regexp_match
        [ :regexp_match, regexp_match ]
      else
        nil
      end
    end

    def find_matching_option results
      type, opt = get_best_match(results)

      unless type
        raise OptionException.new "#{name}: invalid option '#{results.current_arg}'"
      end

      [ type, opt ]
    end

    def set_option results
      type, opt = find_matching_option(results)

      case type
      when :tag_match
        arg = results.next_arg
        opt.set_value_for_tag results, arg
      when :negative_match
        arg = results.next_arg
        opt.set_value_negative results, arg
      when :regexp_match
        arg = results.next_arg
        opt.set_value_regexp results, arg
      end

      opt
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
    
    def unset results, key
      if opt = find_by_name(key)
        results.unset_value opt.name
      end
    end
  end
end
