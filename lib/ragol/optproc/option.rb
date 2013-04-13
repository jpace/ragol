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

    def name
      @name ||= (@matchers.tags && @matchers.tags.tags[0].sub(%r{^\-+}, '')) || (@matchers.regexps && @matchers.regexps.tags[0].to_s)
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

    def match_next_value results
      if @argreqtype == true
        val = results.shift_arg
        val && do_match(val)
      elsif val = results.current_arg
        if val[0] == '-'
          nil
        else
          results.shift_arg
          do_match(val)
        end
      else
        nil
      end
    end

    def set_value_for_tag results, arg
      md = if @argreqtype
             take_eq_value(arg) || match_next_value(results) || argument_missing
           else
             true
           end

      set_option_value md, arg, results
    end

    def set_value_regexp results, arg
      md = @matchers.regexp_match? arg
      set_option_value md, arg, results
    end

    def set_option_value md, arg, results
      value = md == true ? true : convert(md)
      setargs = [ value, arg, results.unprocessed ][0 ... @setter.arity]
      @setter.call(*setargs)
    end
    
    def to_s
      @matchers.to_s
    end

    def post_process optset, results, argslist
    end
  end
end
