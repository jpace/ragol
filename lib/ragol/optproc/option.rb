#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/optproc/errors'
require 'ragol/optproc/regexps'
require 'ragol/optproc/tags'
require 'ragol/optproc/args'

module OptProc
  class Option
    include Logue::Loggable

    class << self
      alias_method :old_new, :new
      def new(*args, &blk)
        optargs = OptionArguments.new(*args)
        optcls = optargs.option_class
        optcls.old_new(optargs, args, &blk)
      end
    end

    def initialize(optargs, args, &blk)
      oldargs = args[0]
      
      @rcfield = oldargs[:rcfield] || oldargs[:rc]
      @rcfield = [ @rcfield ].flatten if @rcfield
      
      @setter = blk || oldargs[:set]

      @argreqtype = optargs.required

      @regexps = optargs.regexps && Regexps.new([ optargs.regexps ].flatten)
      @tags = optargs.tags && Tags.new(optargs.tags)
    end

    def value_regexp
    end

    def convert md
      md
    end

    def match_rc? field
      @rcfield && @rcfield.include?(field)
    end

    def match_score args
      return if args.empty?
      opt = args[0]
      return unless opt && opt[0] == '-'
      
      (@regexps && @regexps.score(opt)) || (@tags && @tags.score(opt))
    end

    def do_match val
      valuere = value_regexp
      if valuere
        unless md = valuere.match(val)
          raise InvalidArgument.new val
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
      raise MissingExpectedArgument.new if @argreqtype == :required
    end

    def match_next_value args
      val = args.shift
      if @argreqtype == :required
        val && do_match(val)
      elsif val
        if val[0] == '-'
          args.unshift val
          nil
        else
          do_match(val)
        end
      else
        nil
      end
    end
    
    def take_value opt, args
      if @argreqtype
        take_eq_value(opt) || match_next_value(args) || argument_missing
      end
    end

    def set_value args
      opt = args.shift
      md = nil
      begin
        md = (@regexps && @regexps.match(opt)) || take_value(opt, args)
      rescue InvalidArgument => e
        raise "invalid argument '#{e.value}' for option: #{self}"
      rescue MissingExpectedArgument => e
        raise "value expected for option: #{self}"
      end
      
      value = convert md

      setargs = [ value, opt, args ][0 ... @setter.arity]
      @setter.call(*setargs)
    end

    def to_s
      return @tags.to_s if @tags
      return "" unless @regexps
      @regexps.to_s
    end
  end

  class DefaultOption < Option
    def convert md
      return unless val = md && md[1]
      convert_value val
    end
  end

  class BooleanOption < DefaultOption
    TRUE = %w{ yes true on }
    FALSE = %w{ no false off }
    
    REGEXP = Regexp.new('^(' + (TRUE | FALSE).join('|') + ')$', Regexp::IGNORECASE)

    def value_regexp
      REGEXP
    end
    
    def convert_value val
      to_boolean val
    end

    def to_boolean val
      TRUE.include? val.downcase
    end
  end

  class StringOption < DefaultOption
    REGEXP = Regexp.new '^ [\"\']? (.*?) [\"\']? $ ', Regexp::EXTENDED
    
    def value_regexp
      REGEXP
    end
    
    def convert_value val
      val
    end
  end

  class IntegerOption < DefaultOption
    REGEXP = Regexp.new '^ ([\-\+]?\d+) $ ', Regexp::EXTENDED
    
    def value_regexp
      REGEXP
    end
    
    def convert_value val
      val.to_i
    end
  end

  class FloatOption < DefaultOption
    REGEXP = Regexp.new '^ ([\-\+]?\d* (?:\.\d+)?) $ ', Regexp::EXTENDED
    
    def value_regexp
      REGEXP
    end
    
    def convert_value val
      val.to_f
    end
  end

  class RegexpOption < Option
    def value_regexp
      nil
    end
    
    # not implemented
    def convert md
      md
    end
  end
end
