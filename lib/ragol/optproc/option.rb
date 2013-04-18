#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/args'
require 'ragol/common/option'

module OptProc
  class Option < Ragol::Option
    attr_reader :description

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

      @description = 'none'
      options = Hash.new
      options[:process] = blk || optargs.process
      options[:takesvalue] = optargs.valuereq
      options[:regexps] = optargs.regexps
      options[:unsets] = optargs.unsets
      options[:tags] = optargs.tags
      
      tag = nil
      name = nil
      
      super tag, name, options
    end

    def name
      @matchers.name
    end

    def match_rc? field
      @rcnames && @rcnames.include?(field)
    end
  end
end
