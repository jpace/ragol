#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/optproc/args'
require 'ragol/common/matchers'

module OptProc
  class Option
    include Logue::Loggable

    attr_reader :matchers

    class << self
      alias_method :old_new, :new
      def new(*args, &blk)
        optargs = OptionArguments.new(*args)
        optcls = optargs.option_class
        optcls.old_new(optargs, &blk)
      end
    end

    def initialize(optargs, &blk)
      @rcnames = [ optargs.rcnames ].flatten
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

    def match_next_value argslist
      if @argreqtype == true
        val = argslist.shift_arg
        val && do_match(val)
      elsif val = argslist[0]
        if val[0] == '-'
          nil
        else
          argslist.shift_arg
          do_match(val)
        end
      else
        nil
      end
    end

    def set_value argslist
      opt = argslist.next_arg
      md = nil

      unless md = @matchers.regexp_match?(opt)
        if @argreqtype
          md = take_eq_value(opt) || match_next_value(argslist) || argument_missing
        end
      end
      
      value = convert md
      
      setargs = [ value, opt, argslist.args ][0 ... @setter.arity]
      @setter.call(*setargs)
    end
    
    def to_s
      @matchers.to_s
    end
  end
end
