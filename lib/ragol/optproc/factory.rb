#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/optproc/option'
require 'singleton'

module OptProc
  class OptionFactory
    include Logue::Loggable, Singleton

    TYPES_TO_CLASSES = {
      :boolean => BooleanOption,
      :string  => StringOption,
      :float   => FloatOption,
      :integer => IntegerOption,
      :regexp  => RegexpOption
    }

    def create args = Hash.new, &blk
      optargs = args[:arg] || Array.new

      required = case 
                 when optargs.include?(:required)
                   :required
                 when optargs.include?(:optional)
                   :optional
                 when optargs.include?(:none)
                   nil
                 end

      args[:required] = required
      
      if opttype = (TYPES_TO_CLASSES.keys & optargs)[0]
        args[:required] ||= :required
      end
      
      regexps = args[:regexps] || args[:regexp] || args[:res]
      tags = args[:tags]

      optcls = case opttype
               when :boolean
                 BooleanOption
               when :string
                 StringOption
               when :float
                 FloatOption
               when :integer
                 IntegerOption
               when :regexp
                 RegexpOption
               else
                 Option
               end

      optcls.old_new tags, regexps, args, &blk
    end
  end
end
