#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/optproc/errors'
require 'ragol/optproc/regexps'
require 'ragol/optproc/tags'
require 'ragol/optproc/args'

module OptProc
  class Option
    include Logue::Loggable

    class << self
      alias_method :old_new, :new
      def new(*args, &blk)
        optargs = OptionArguments.new(*args)
        optcls = optargs.option_class
        optcls.old_new(optargs, args, &blk)
      end
    end

    def initialize(optargs, args, &blk)
      oldargs = args[0]
      
      @rcfield = oldargs[:rcfield] || oldargs[:rc]
      @rcfield = [ @rcfield ].flatten if @rcfield
      
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
      @rcfield && @rcfield.include?(field)
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
          raise InvalidArgument.new val
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
      raise MissingExpectedArgument.new if @argreqtype == true
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
    
    def take_value opt, args
      if @argreqtype
        take_eq_value(opt) || match_next_value(args) || argument_missing
      end
    end

    def set_value args
      opt = args.shift
      md = nil
      begin
        convert nil
        unless md = @regexps && @regexps.match(opt)
          md = take_value(opt, args)
        end
      rescue InvalidArgument => e
        raise "invalid argument '#{e.value}' for option: #{self}"
      rescue MissingExpectedArgument => e
        raise "value expected for option: #{self}"
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
