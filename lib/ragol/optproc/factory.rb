#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'riel/enumerable'
require 'ragol/optproc/type'
require 'ragol/optproc/argument'
require 'ragol/optproc/tag_option'
require 'ragol/optproc/regexp_option'
require 'singleton'

module OptProc
  class OptionFactory
    include Logue::Loggable, Singleton

    def create args = Hash.new, &blk
      optargs = [ args[:arg] ].flatten.compact

      reqtype = case
                when optargs.include?(:required)
                  RequiredOptionArgument
                when optargs.include?(:optional)
                  OptionalOptionArgument
                when optargs.include?(:none)
                  nil
                end
      
      opttype = [ (OptProc::ARG_TYPES.keys & optargs) ].flatten.compact[0]
      debug "opttype: #{opttype}"
      
      if opttype
        reqtype ||= RequiredOptionArgument
        mod = OptProc::ARG_TYPES[opttype]
        re = mod.const_get('REGEXP')
        args[:value_regexp] = re
      end
      
      args[:reqtype] = reqtype

      if args[:regexps] || args[:regexp] || args[:res]
        create_regexp_option opttype, args, &blk
      else
        create_tag_option opttype, args, &blk
      end
    end
    
    def create_regexp_option opttype, args, &blk
      opt = RegexpOption.old_new args, &blk
      if mod = OptProc::ARG_TYPES[opttype]
        opt.send :extend, mod
      end
      opt
    end

    def create_tag_option opttype, args, &blk
      opt = TagOption.old_new args, &blk
      if mod = OptProc::ARG_TYPES[opttype]
        opt.send :extend, mod
      end
      opt
    end
  end
end
