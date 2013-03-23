#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'

module OptProc
  class OptionArguments
    include Logue::Loggable

    attr_reader :required
    attr_reader :regexps
    attr_reader :tags
    attr_reader :option_class

    @@types_to_classes = nil

    def initialize args = Hash.new
      require 'ragol/optproc/boolean_option'
      require 'ragol/optproc/fixnum_option'
      require 'ragol/optproc/float_option'
      require 'ragol/optproc/regexp_option'
      require 'ragol/optproc/string_option'

      optargs = args[:arg] || Array.new

      @@types_to_classes ||= {
        :boolean => BooleanOption,
        :string  => StringOption,
        :float   => FloatOption,
        :integer => FixnumOption,
        :fixnum  => FixnumOption,
        :regexp  => RegexpOption
      }

      @required = case 
                  when optargs.include?(:required)
                    :required
                  when optargs.include?(:optional)
                    :optional
                  when optargs.include?(:none)
                    nil
                  end

      if opttype = (@@types_to_classes.keys & optargs)[0]
        @required ||= :required
      end
      
      @regexps = args[:regexps] || args[:regexp] || args[:res]
      @tags = args[:tags]

      @option_class = @@types_to_classes[opttype] || Option
    end
  end
end
