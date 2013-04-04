#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/optproc/tags'
require 'ragol/optproc/regexps'

module OptProc
  class OptionArguments
    include Logue::Loggable

    VALUE_TYPES = [
                   :boolean,
                   :string,
                   :float,
                   :integer,
                   :fixnum,
                   :regexp
                  ]
    
    attr_reader :required
    attr_reader :regexps
    attr_reader :tags
    attr_reader :option_class

    @@types_to_classes = nil

    OLD_OPTIONS = {
      :regexps => [ Regexp.new('--fo+'), Regexp.new('--ba*r') ],
      :tags => [ '--foo', '-b' ],
      :arg => [ [ :boolean, :string, :float, :integer, :fixnum, :regexp ], [ :optional, :required, :none ] ],
      :set => Proc.new { }
    }
    
    NEW_OPTIONS = {
      :regexps => [ Regexp.new('--fo+'), Regexp.new('--ba*r') ],
      :tags => [ '--foo', '-b' ],
      :rcnames => [ 'foo', 'foobar' ],
      :valuereq => [ true, :optional, false ],
      :valuetype => [ :boolean, :string, :float, :integer, :fixnum, :regexp ],
      :default => nil,
      :process => Proc.new { },
      :postproc => Proc.new { }
    }

    def self.common_element alist, blist
      (alist & blist)[0]
    end
    
    def self.convert_arguments origargs
      args = Hash.new

      oldregexpfields = [ :regexps, :regexp, :res, :re ]
      args[:regexps] = if regexps = oldregexpfields.collect { |field| origargs[field] }.compact[0]
                         [ regexps ].flatten
                       else
                         nil
                       end
      
      args[:tags] = origargs[:tags]

      if valueargs = origargs[:arg]
        if valuetype = common_element(valueargs, VALUE_TYPES)
          args[:valuetype] = valuetype == :integer ? :fixnum : valuetype
        end

        valuereq = common_element(valueargs, [ :optional, :required, :none ])
        args[:valuereq] = case valuereq
                          when :optional
                            :optional
                          when :required
                            true
                          when :none, nil
                            !(valuetype.nil?)
                          end
      else
        args[:valuereq] = origargs[:valuereq] || false
        args[:valuetype] = origargs[:valuetype]
      end

      args[:process] = origargs[:process] || origargs[:set]
      args[:postproc] = origargs[:postproc]
      args[:rcnames] = origargs[:rcnames]
      args[:default] = origargs[:default]
      
      args
    end
    
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
      
      regexps = args[:regexps] || args[:regexp] || args[:res]
      @regexps = regexps && Regexps.new([ regexps ].flatten)
      
      tags = args[:tags]
      @tags = tags && Tags.new(tags)
      
      @option_class = @@types_to_classes[opttype] || Option
    end
  end
end
