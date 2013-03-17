#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'riel/enumerable'
require 'ragol/optproc/value'
require 'ragol/optproc/argument'

module OptProc
  class Option
    include Logue::Loggable

    class << self
      alias_method :old_new, :new
      def new args = Hash.new, &blk
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

        if opttype
          reqtype ||= RequiredOptionArgument
          args[:valuere] = OptProc::ARG_TYPES[opttype][0]
          args[:opttype] = OptProc::ARG_TYPES[opttype][1]
        end
        
        args[:reqtype] = reqtype
        
        if args[:regexps] || args[:regexp] || args[:res]
          RegexpOption.old_new args, &blk
        else
          TagOption.old_new args, &blk
        end
      end
    end

    def initialize args = Hash.new, &blk
      @rcfield = args[:rcfield] || args[:rc]
      @rcfield = [ @rcfield ].flatten if @rcfield
      
      @setter = blk || args[:set]
      
      valuere    = args[:valuere]
      opttypecls = args[:opttype]
      optargcls  = args[:reqtype]

      @optvalue = opttypecls && opttypecls.new
      @optarg = optargcls && optargcls.new(valuere)
    end

    def match_rc? field
      @rcfield && @rcfield.include?(field)
    end

    def match_score args
      return if args.empty?
      opt = args[0]
      return unless opt && opt[0] == '-'
      match_tag_score opt
    end

    def set_value args
      opt = args.shift
      md = take_value opt, args      
      value = @optvalue ? @optvalue.convert(md) : md

      ary = [ value, opt, args ]
      ary.extend RIEL::EnumerableExt
      setargs = ary.select_with_index { |x, i| i < @setter.arity }
      @setter.call(*setargs)
    end
  end

  class TagOption < Option
    attr_reader :tags
    
    def initialize args = Hash.new, &blk
      @tags = args[:tags] || Array.new
      super
    end

    def match_tag_score opt
      tag = opt.split('=', 2)[0] || opt
      return unless tm = @tags.detect do |t|
        t.index(tag) == 0 && tag.length <= t.length
      end
      
      if tag.length == tm.length
        1.0
      else
        tag.length.to_f * 0.01
      end
    end

    def take_value opt, args
      begin
        @optarg && @optarg.take_value(opt, args)
      rescue InvalidArgument => e
        raise "invalid argument '#{e.value}' for option: #{@tags.join(', ')}"
      rescue MissingExpectedArgument => e
        raise "value expected for option: #{@tags.join(', ')}"
      end
    end
  end

  class RegexpOption < Option
    attr_reader :regexps
    
    def initialize args = Hash.new, &blk
      @regexps = args[:regexps] || args[:regexp] || args[:res]
      @regexps = [ @regexps ].flatten
      super
    end

    def match_tag_score opt
      return 1.0 if @regexps.find { |re| re.match(opt) }
    end

    def take_value opt, args
      @regexps.collect { |re| re.match(opt) }.detect { |x| x }
    end
  end
end
