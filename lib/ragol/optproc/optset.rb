#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'
require 'ragol/common/results'
require 'ragol/common/option_set'

module OptProc
  class OptionSet < Ragol::OptionSet
    include Logue::Loggable
    
    attr_reader :options
    
    def initialize data
      options = data.collect do |optdata|
        OptProc::Option.new optdata
      end
      super(*options)
    end

    def name
      'testing'
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

    # this is a legacy method; process should be used instead.
    def process_option argslist
      set_option argslist
    end
    
    def set_option results
      type, opt = find_matching_option(results)

      if type == :regexp_match
        arg = results.next_arg
        opt.set_value_regexp results, arg
      elsif type == :tag_match
        arg = results.next_arg
        opt.set_value_for_tag results, arg
      else
        nil
      end
      opt
    end
  end
end
