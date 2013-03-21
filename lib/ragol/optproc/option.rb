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
      def new(*args, &blk)
        require 'ragol/optproc/factory'
        
        factory = OptionFactory.instance
        factory.create(*args, &blk)
      end
    end

    def initialize(*args, &blk)
      optargs = args[0]
      
      @rcfield = optargs[:rcfield] || optargs[:rc]
      @rcfield = [ @rcfield ].flatten if @rcfield
      
      @setter = blk || optargs[:set]
      
      optargcls = optargs[:reqtype]

      @optarg = optargcls && optargcls.new(optargs[:value_regexp])
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
end
