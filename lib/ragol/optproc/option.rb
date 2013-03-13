#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'riel/enumerable'

module OptProc
  class OptionTags
    attr_reader :tags

    def initialize tags
      @tags = tags
    end

    def match_score tag
      tm = @tags.detect do |t|
        t.index(tag) == 0 && tag.length <= t.length
      end

      return unless tm
      
      if tag.length == tm.length
        1.0
      else
        tag.length.to_f * 0.01
      end
    end

    def to_s
      @tags.join(', ')
    end
  end

  class OptionValue
    def initialize argtype
      @argtype = argtype
    end
    
    def convert md
      return md if @argtype.nil? || @argtype == :regexp
      unless val = md && md[1]
        # we return nil for undefined, as opposed to false for defined
        return @argtype == :boolean || nil
      end

      case @argtype
      when :string
        val
      when :integer
        val.to_i
      when :float
        val.to_f
      when :boolean
        to_boolean val
      when nil
        val
      else
        debug { "unknown argument type: #{@argtype.inspect}" }
      end
    end

    def to_boolean val
      %w{ yes true on soitenly }.include? val.downcase
    end
  end
  
  class Option
    include Logue::Loggable

    attr_reader :tags, :regexps

    ARG_INTEGER = %r{^ ([\-\+]?\d+)               $ }x
    ARG_FLOAT   = %r{^ ([\-\+]?\d* (?:\.\d+)?)    $ }x
    ARG_STRING  = %r{^ [\"\']? (.*?) [\"\']?      $ }x
    ARG_BOOLEAN = %r{^ (yes|true|on|no|false|off) $ }ix

    ARG_TYPES = Array.new
    ARG_TYPES << [ :integer, ARG_INTEGER ]
    ARG_TYPES << [ :float,   ARG_FLOAT   ]
    ARG_TYPES << [ :string,  ARG_STRING  ]
    ARG_TYPES << [ :boolean, ARG_BOOLEAN ]

    def initialize args = Hash.new, &blk
      @tags = OptionTags.new(args[:tags] || Array.new)

      @rcfield = args[:rcfield] || args[:rc]
      @rcfield = [ @rcfield ].flatten
      
      @set = blk || args[:set]
      
      @type = nil
      @valuere = nil
      
      @argtype = nil

      @regexps = args[:regexps] || args[:regexp] || args[:res]
      @regexps = [ @regexps ].flatten if @regexps

      if args[:arg]
        demargs = args[:arg].dup
        while arg = demargs.shift
          case arg
          when :required
            @type = :required
          when :optional
            @type = :optional
          when :none
            @type = nil
          when :regexp
            @valuere = demargs.shift
          else
            if re = ARG_TYPES.assoc(arg)
              @valuere = re[1]
              @argtype = arg
              @type ||= :required
            end
          end
        end
      end
    end

    def inspect
      super + '[' + @tags.tags.collect { |t| t.inspect }.join(" ") + ']'
    end

    def to_str
      to_s
    end

    def to_s
      @tags.to_s
    end

    def match_rc? field
      @rcfield && @rcfield.include?(field)
    end

    def match_value val
      @valuere && @valuere.match(val)
    end

    def match_score args
      return if args.empty?
      opt = args[0]
      return unless opt && %r{^-}.match(opt)

      if @regexps && @regexps.find { |re| re.match(opt) }
        1.0
      else
        tag = opt.split('=', 2)[0] || opt
        @tags.match_score tag
      end
    end
    
    def get_required_value val, args
      if val
        # already have value from split
      elsif args.size > 0
        val = args.shift
      else
        raise "value expected for option: #{self}"
      end

      md = nil

      if val
        md = match_value(val)
        md && md[1]
      end
      md
    end

    def get_optional_value val, args
      md = nil

      if val
        # already have value
        md = @valuere && @valuere.match(val)
      elsif args.size > 0
        if %r{^-}.match args[0]
          # skipping next value; apparently option
        else
          md = match_value(args[0])
          if md && md[1]
            # value matches
            args.shift
          end
        end
      end
      md
    end

    def set_value args
      opt = args.shift

      md = nil

      if @regexps
        md = @regexps.collect { |re| re.match(opt) }.detect { |x| x }
      end
      
      unless md
        val = opt.split('=', 2)[1]
        if @type == :required
          md = get_required_value val, args
        elsif @type == :optional
          md = get_optional_value val, args
        end
      end
      
      ov = OptionValue.new @argtype
      value = ov.convert md

      set value, opt, args
    end

    def set val, opt = nil, args = nil
      ary = [ val, opt, args ]
      ary.extend RIEL::EnumerableExt
      setargs = ary.select_with_index { |x, i| i < @set.arity }
      @set.call(*setargs)
    end
  end
end
