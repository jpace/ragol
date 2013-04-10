#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'
require 'ragol/synoption/exception'
require 'ragol/common/argslist'

module OptProc
  class OptionSet
    attr_reader :options
    
    def initialize data
      @options = data.collect do |optdata|
        OptProc::Option.new optdata
      end
    end

    COMBINED_OPTS_RES = [
                         #               -number       non-num
                         Regexp.new('^ ( - \d+   )     ( \D+.* ) $ ', Regexp::EXTENDED),
                         #               -letter       anything
                         Regexp.new('^ ( - [a-zA-Z] )  ( .+    ) $ ', Regexp::EXTENDED)
                        ]

    def process args
      argslist = args.kind_of?(Ragol::ArgsList) ? args : Ragol::ArgsList.new(args)
      
      while !argslist.empty?
        if argslist.end_of_options?
          argslist.shift_arg
          return
        elsif argslist.current_arg[0] == '-'
          return unless process_option(argslist)
        else
          return
        end
      end
    end

    def process_option_orig args
      argslist = args.kind_of?(Ragol::ArgsList) ? args : Ragol::ArgsList.new(args)
      
      opt = argslist.args[0]
      if md = COMBINED_OPTS_RES.collect { |re| re.match opt }.detect { |x| x }
        lhs = md[1]
        rhs = "-" + md[2]
        argslist.args[0, 1] = lhs, rhs
        process_option argslist
      else
        set_option argslist
      end
    end

    def process_option args
      argslist = args.kind_of?(Ragol::ArgsList) ? args : Ragol::ArgsList.new(args)
      
      opt = argslist.args[0]
      set_option argslist
    end

    def set_option_value option, argslist
      option.set_value argslist
      option
    end

    def get_best_match argslist
      bestmatch = nil
      bestopts = Array.new

      @options.each do |option|
        if score = option.match_score(argslist.current_arg)
          if score >= 1.0
            return [ option ]
          elsif !bestmatch || bestmatch <= score
            bestmatch = score
            bestopts << option
          end
        end
      end
      
      bestmatch && bestopts
    end
    
    def set_option argslist
      unless bestopts = get_best_match(argslist)
        raise "option '#{argslist.args[0]}' is not valid"
      end
      
      if bestopts.size == 1
        set_option_value bestopts[0], argslist
      else
        optstr = bestopts.collect { |opt| '(' + opt.to_s + ')' }.join(', ')
        raise "ambiguous match of '#{argslist.args[0]}'; matches options: #{optstr}"
      end
    end
  end
end
