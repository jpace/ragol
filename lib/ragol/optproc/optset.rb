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

    def process_option args
      opt = args[0]

      if md = COMBINED_OPTS_RES.collect { |re| re.match opt }.detect { |x| x }
        puts "md: #{md}"
        lhs = md[1]
        rhs = "-" + md[2]
        args[0, 1] = lhs, rhs
        process_option args
      else
        set_option args
      end
    end

    def set_option args
      bestmatch = nil
      bestopts = Array.new
      
      @options.each do |option|
        next unless matchval = option.match(args)
        if matchval >= 1.0
          # exact match:
          option.set_value args
          return option
        elsif !bestmatch || bestmatch <= matchval
          bestmatch = matchval
          bestopts << option
        end
      end
      
      return unless bestmatch

      if bestopts.size == 1
        bestopts[0].set_value args
        bestopts[0]
      else
        optstr = bestopts.collect { |y| '(' + y.tags.join(', ') + ')' }.join(', ')
        raise "ambiguous match of '#{args[0]}'; matches options: #{optstr}"
      end
    end
  end
end
