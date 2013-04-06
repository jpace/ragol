#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/common/tags'
require 'ragol/optproc/args'

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
      rcnames = optargs.rcnames
      @rcnames = rcnames && [ rcnames ].flatten
      
      @setter = blk || optargs.process

      @argreqtype = optargs.valuereq

      @regexps = optargs.regexps
      @tags = optargs.tags
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
      return if args.empty?
      opt = args[0]
      return unless opt && opt[0] == '-'
      
      (@regexps && @regexps.score(opt)) || (@tags && @tags.score(opt))
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

      unless md = @regexps && @regexps.match?(opt)
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
      str << @tags.to_s if @tags
      str << @regexps.to_s if @regexps
      str
    end
  end
end
