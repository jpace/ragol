#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/optproc/args'
require 'singleton'

module OptProc
  class OptionFactory
    include Logue::Loggable, Singleton

    def create args = Hash.new, &blk
      optargs = OptionArguments.new args

      optcls = optargs.option_class
      
      optcls.old_new optargs.tags, optargs.regexps, optargs.required, args, &blk
    end
  end
end
