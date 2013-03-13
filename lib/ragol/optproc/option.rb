#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'riel/enumerable'

module OptProc
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
      @tags = args[:tags] || Array.new
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
      '[' + @tags.collect { |t| t.inspect }.join(" ") + ']'
    end

    def to_str
      to_s
    end

    def to_s
      @tags.join " "
    end

    def match_rc? field
      @rcfield && @rcfield.include?(field)
    end

    def match_value val
      @md = @valuere && @valuere.match(val)
      @md && @md[1]
    end

    def match_tag tag
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
    
    def match args, opt = args[0]
      return nil unless %r{^-}.match opt

      tag = opt.split('=', 2)[0] || opt

      @md = nil

      if @regexps && (@md = @regexps.collect { |re| re.match(opt) }.detect { |x| x })
        1.0
      else
        match_tag tag
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
      if val
        match_value val
      end
      val
    end

    def get_optional_value val, args
      if val
        # already have value
        match_value val
      elsif args.size > 0
        if %r{^-}.match args[0]
          # skipping next value; apparently option
        elsif match_value(args[0])
          # value matches
          args.shift
        end
      end
      val
    end

    def set_value args
      opt = args.shift
      val = opt.split('=', 2)[1]
      
      if @md
        # already have match data
      elsif @type == :required
        val = get_required_value val, args
      elsif @type == :optional
        val = get_optional_value val, args
      end
      
      value = value_from_match @md
      set value, opt, args
    end

    def value_from_match md
      if md
        if @argtype.nil? || @argtype == :regexp
          md
        else
          convert_value md[1]
        end
      elsif @argtype == :boolean
        true
      end
    end

    def convert_value val
      if val
        case @argtype
        when :string
          val
        when :integer
          val.to_i
        when :float
          val.to_f
        when :boolean
          to_boolean val
        when :regexp
          val
        when nil
          val
        else
          debug { "unknown argument type: #{@argtype.inspect}" }
        end
      elsif @argtype == :boolean
        true
      end
    end

    def to_boolean val
      %w{ yes true on soitenly }.include? val.downcase
    end

    def set val, opt = nil, args = nil
      ary = [ val, opt, args ]
      ary.extend RIEL::EnumerableExt
      setargs = ary.select_with_index { |x, i| i < @set.arity }
      @set.call(*setargs)
    end
  end
end
