#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/args'
require 'ragol/common/option'

module OptProc
  class Option < Ragol::Option
    include Logue::Loggable
    
    TYPES_TO_CLASSES = {
      :boolean => :BooleanOption,
      :string  => :StringOption,
      :float   => :FloatOption,
      :integer => :FixnumOption,
      :fixnum  => :FixnumOption,
      :regexp  => :RegexpOption
    }

    attr_reader :description

    class << self
      alias_method :old_new, :new
      def new(*args, &blk)
        optargs = OptionArguments.new(*args)

        opttype = optargs[:valuetype]
        clssym = TYPES_TO_CLASSES[opttype]
        optcls = if clssym
                   'ragol/optproc/' + clssym.to_s.sub('Option', '_option').downcase
                   OptProc.const_get(clssym)
                 else
                   Option
                 end

        optcls.old_new(optargs, &blk)
      end
    end

    def initialize(optargs, &blk)
      newargs = optargs.newargs
      @rcnames = [ optargs[:rcnames] ].flatten

      @description = 'none'

      options = optargs.dup
      options[:process] = blk if blk
      
      tag = nil
      name = nil
      
      super tag, name, options
    end

    def name
      @matchers.name
    end

    def match_rc? field
      @rcnames && @rcnames.include?(field)
    end
  end
end
