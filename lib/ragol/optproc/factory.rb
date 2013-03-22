#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/optproc/type'
require 'ragol/optproc/option'
require 'singleton'

module OptProc
  class OptionFactory
    include Logue::Loggable, Singleton

    def create args = Hash.new, &blk
      optargs = [ args[:arg] ].flatten.compact

      required = case 
                 when optargs.include?(:required)
                   :required
                 when optargs.include?(:optional)
                   :optional
                 when optargs.include?(:none)
                   nil
                 end

      args[:required] = required
      
      opttype = [ (OptProc::ARG_TYPES.keys & optargs) ].flatten.compact[0]
      debug "opttype: #{opttype}"
      
      if opttype
        args[:required] ||= :required
        mod = OptProc::ARG_TYPES[opttype]
        re = mod.const_get('REGEXP')
        args[:value_regexp] = re
      end
      
      regexps = args[:regexps] || args[:regexp] || args[:res]
      tags = args[:tags]

      optntype = nil

      opt = Option.old_new tags, regexps, optntype, args, &blk
      if mod = OptProc::ARG_TYPES[opttype]
        opt.send :extend, mod
      end
      opt
    end
  end
end
