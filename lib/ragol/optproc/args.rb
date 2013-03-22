#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'

module OptProc
  class OptionArguments
    include Logue::Loggable

    TYPES_TO_CLASSES = {
      :boolean => BooleanOption,
      :string  => StringOption,
      :float   => FloatOption,
      :integer => IntegerOption,
      :regexp  => RegexpOption
    }

    attr_reader :required
    attr_reader :regexps
    attr_reader :tags
    attr_reader :option_class

    def initialize args = Hash.new
      optargs = args[:arg] || Array.new

      @required = case 
                  when optargs.include?(:required)
                    :required
                  when optargs.include?(:optional)
                    :optional
                  when optargs.include?(:none)
                    nil
                  end

      if opttype = (TYPES_TO_CLASSES.keys & optargs)[0]
        @required ||= :required
      end
      
      @regexps = args[:regexps] || args[:regexp] || args[:res]
      @tags = args[:tags]

      @option_class = case opttype
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
    end
  end
end
