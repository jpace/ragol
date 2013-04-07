#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/common/tags'
require 'ragol/optproc/args'
require 'ragol/common/matchers'

module OptProc
  class Option
    include Logue::Loggable

    class << self
      alias_method :old_new, :new
      def new(*args, &blk)
        optargs = OptionArguments.new(*args)
        optcls = optargs.option_class
        optcls.old_new(optargs, &blk)
      end
    end

    def initialize(optargs, &blk)
      @rcnames = optargs.rcnames
      @setter = blk || optargs.process
      @argreqtype = optargs.valuereq
      @matchers = Ragol::Matchers.new optargs.tags, nil, optargs.regexps
    end

    def value_regexp
    end

    def convert md
      md
    end

    def match_rc? field
      @rcnames && @rcnames.include?(field)
    end

    def match_score args
      opt = args[0]
      # return unless opt && opt[0] == '-'
      
      (@matchers.regexp && @matchers.regexp.score(opt)) || (@matchers.exact && @matchers.exact.score(opt))
    end

    def do_match val
      valuere = value_regexp
      if valuere
        unless md = valuere.match(val)
          raise "invalid argument '#{val}' for option: #{self}"
        end
        md
      else
        val
      end
    end

    def take_eq_value opt
      val = opt.split('=', 2)[1]
      val && do_match(val)
    end

    def argument_missing
      if @argreqtype == true
        raise "value expected for option: #{self}"
      end
    end

    def match_next_value args
      val = args.shift
      if @argreqtype == true
        val && do_match(val)
      elsif val
        if val[0] == '-'
          args.unshift val
          nil
        else
          do_match(val)
        end
      else
        nil
      end
    end

    def set_value args
      opt = args.shift
      md = nil

      unless md = @matchers.regexp && @matchers.regexp.match?(opt)
        if @argreqtype
          md = take_eq_value(opt) || match_next_value(args) || argument_missing
        end
      end
      
      value = convert md
      
      setargs = [ value, opt, args ][0 ... @setter.arity]
      @setter.call(*setargs)
    end

    def to_s
      str = ""
      str << @matchers.exact.to_s if @matchers.exact
      str << @matchers.regexp.to_s if @matchers.regexp
      str
    end
  end
end
