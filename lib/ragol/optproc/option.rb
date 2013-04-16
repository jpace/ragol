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
  end
end
