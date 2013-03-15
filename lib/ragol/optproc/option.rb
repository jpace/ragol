#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'riel/enumerable'
require 'ragol/optproc/tags'
require 'ragol/optproc/value'
require 'ragol/optproc/argument'

module OptProc
  class Option
    include Logue::Loggable

    attr_reader :tags, :regexps

    ARG_INTEGER = %r{^ ([\-\+]?\d+)               $ }x
    ARG_FLOAT   = %r{^ ([\-\+]?\d* (?:\.\d+)?)    $ }x
    ARG_STRING  = %r{^ [\"\']? (.*?) [\"\']?      $ }x
    ARG_BOOLEAN = %r{^ (yes|true|on|no|false|off) $ }ix

    ARG_TYPES = Hash[:integer => ARG_INTEGER,
                     :float   => ARG_FLOAT,
                     :string  => ARG_STRING,
                     :boolean => ARG_BOOLEAN]

    def initialize args = Hash.new, &blk
      @tags = OptionTags.new(args[:tags] || Array.new)

      @rcfield = args[:rcfield] || args[:rc]
      @rcfield = [ @rcfield ].flatten if @rcfield
      
      @setter = blk || args[:set]
      
      valuere = nil      
      argtype = nil

      @regexps = args[:regexps] || args[:regexp] || args[:res]
      @regexps = [ @regexps ].flatten if @regexps

      optargcls = nil

      if args[:arg]
        demargs = args[:arg].dup
        while arg = demargs.shift
          case arg
          when :required
            optargcls = RequiredOptionArgument
          when :optional
            optargcls = OptionalOptionArgument
          when :none
            optargcls = OptionArgument
          when :regexp
            valuere = demargs.shift
          else
            if re = ARG_TYPES[arg]
              valuere = re
              argtype = arg
              optargcls ||= RequiredOptionArgument
            end
          end
        end
      end

      optvalcls = argtype && eval('OptProc::' + argtype.to_s.capitalize + 'Value')
      @optvalue = optvalcls && optvalcls.new
      
      optargcls ||= OptionArgument
      @optarg = optargcls.new @tags, valuere
    end

    def inspect
      super + '[' + @tags.inspect + ']'
    end

    def to_s
      @tags.to_s
    end

    def match_rc? field
      @rcfield && @rcfield.include?(field)
    end

    def match_score args
      return if args.empty?
      opt = args[0]
      return unless opt && opt[0] == '-'

      if @regexps && @regexps.find { |re| re.match(opt) }
        1.0
      else
        tag = opt.split('=', 2)[0] || opt
        @tags.match_score tag
      end
    end

    def set_value args
      opt = args.shift

      unless md = @regexps && @regexps.collect { |re| re.match(opt) }.detect { |x| x }
        md = @optarg.take_value opt, args
      end
      
      value = @optvalue ? @optvalue.convert(md) : md

      ary = [ value, opt, args ]
      ary.extend RIEL::EnumerableExt
      setargs = ary.select_with_index { |x, i| i < @setter.arity }
      @setter.call(*setargs)
    end
  end
end
