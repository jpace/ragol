#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'riel/enumerable'
require 'ragol/optproc/type'
require 'ragol/optproc/argument'

module OptProc
  class Option
    include Logue::Loggable

    class << self
      alias_method :old_new, :new
      def new args = Hash.new, &blk
        require 'ragol/optproc/factory'
        
        factory = OptionFactory.instance
        factory.create args, &blk
      end
    end

    def initialize args = Hash.new, &blk
      @rcfield = args[:rcfield] || args[:rc]
      @rcfield = [ @rcfield ].flatten if @rcfield
      
      @setter = blk || args[:set]
      
      optargcls = args[:reqtype]

      @optarg = optargcls && optargcls.new(args[:value_regexp])
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
      match_tag_score opt
    end

    def set_value args
      opt = args.shift
      md = take_value opt, args      
      value = convert md

      ary = [ value, opt, args ]
      ary.extend RIEL::EnumerableExt
      setargs = ary.select_with_index { |x, i| i < @setter.arity }
      @setter.call(*setargs)
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
