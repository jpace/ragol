#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'
require 'ragol/synoption/exception'
require 'ragol/common/argslist'
require 'ragol/common/results'

module OptProc
  class OptionSet
    include Logue::Loggable
    
    attr_reader :options
    
    def initialize data
      @options = data.collect do |optdata|
        OptProc::Option.new optdata
      end
    end

    def process args
      results = Ragol::Results.new Array.new, args
      
      while !results.args_empty?
        if results.end_of_options?
          results.shift_arg
          break
        elsif results.current_arg[0] != '-'
          break
        end

        set_option results
      end
    end

    def process_option argslist
      set_option argslist
    end

    def set_option_value option, argslist
      option.set_value argslist
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
        return [ :tag_match, opts.first ]
      elsif negative_match
        return [ :negative_match, negative_match ]
      elsif regexp_match
        return [ :regexp_match, regexp_match ]
      else
        return nil
      end
    end
    
    def set_option results
      type, opt = get_best_match(results.unprocessed)

      unless type
        raise "option '#{results.current_arg}' is not valid"
      end
      
      set_option_value opt, results.unprocessed
    end
  end
end
