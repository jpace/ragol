#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/optproc/args'
require 'ragol/common/option'

module OptProc
  class Option < Ragol::Option
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
      @process = blk || optargs.process
      @argreqtype = optargs.valuereq
      super nil, nil, optargs.tags, nil, optargs.regexps, optargs.unsets, @process
    end

    def name
      @matchers.name
    end

    def match_rc? field
      @rcnames && @rcnames.include?(field)
    end

    def takes_value?
      @argreqtype
    end

    def set_value_regexp results, arg
      md = @matchers.regexp_match? arg
      set_option_value md, arg, results
    end

    def set_option_value md, arg, results
      value = md == true || convert(md)
      if @process
        setargs = [ value, arg, results.unprocessed ][0 ... @process.arity]
        @process.call(*setargs)
      end
      results.set_value name, value
    end
  end
end
