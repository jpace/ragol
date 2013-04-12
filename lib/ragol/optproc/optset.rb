#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'
require 'ragol/synoption/exception'
require 'ragol/common/argslist'
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
      type, opt = get_best_match(results.unprocessed)

      unless type
        raise "option '#{results.current_arg}' is not valid"
      end
      
      opt.set_value results.unprocessed
      opt
    end
  end
end
