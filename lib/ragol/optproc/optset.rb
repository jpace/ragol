#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/optproc/option'

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
      while args
        return unless process_option args
      end
    end

    def process_option args
      opt = args[0]
      if opt == '--'
        args.shift
        return nil
      end

      if md = COMBINED_OPTS_RES.collect { |re| re.match opt }.detect { |x| x }
        lhs = md[1]
        rhs = "-" + md[2]
        args[0, 1] = lhs, rhs
        process_option args
      else
        set_option args
      end
    end

    def set_option_value option, args
      option.set_value args
      option
    end

    def get_best_match args
      bestmatch = nil
      bestopts = Array.new

      @options.each do |option|
        if score = option.match_score(args)
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
    
    def set_option args
      return unless bestopts = get_best_match(args)
      
      if bestopts.size == 1
        set_option_value bestopts[0], args
      else
        optstr = bestopts.collect { |opt| '(' + opt.to_s + ')' }.join(', ')
        raise "ambiguous match of '#{args[0]}'; matches options: #{optstr}"
      end
    end
  end
end
