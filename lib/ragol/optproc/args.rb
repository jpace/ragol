#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/optproc/tags'
require 'ragol/optproc/regexps'

module OptProc
  class OptionArguments
    include Logue::Loggable

    TYPES_TO_CLASSES = {
      :boolean => :BooleanOption,
      :string  => :StringOption,
      :float   => :FloatOption,
      :integer => :FixnumOption,
      :fixnum  => :FixnumOption,
      :regexp  => :RegexpOption
    }
    
    attr_reader :tags
    attr_reader :regexps
    attr_reader :option_class
    attr_reader :process
    attr_reader :postproc
    attr_reader :rcnames
    attr_reader :valuereq
    attr_reader :valuetype
    attr_reader :default

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
        if valuetype = common_element(valueargs, TYPES_TO_CLASSES.keys)
          args[:valuetype] = valuetype == :integer ? :fixnum : valuetype
        end

        if valuetype == :boolean
          args[:valuereq] = false
        else
          valuereq = common_element(valueargs, [ :optional, :required, :none ])
          args[:valuereq] = case valuereq
                            when :optional
                              :optional
                            when :required
                              true
                            when :none, nil
                              !(valuetype.nil?)
                            end
        end
      else
        args[:valuereq] = origargs[:valuereq] || false
        args[:valuetype] = origargs[:valuetype]
      end

      args[:process] = origargs[:process] || origargs[:set]
      args[:postproc] = origargs[:postproc]
      args[:rcnames] = origargs[:rcnames] || origargs[:rc]
      args[:default] = origargs[:default]
      
      args
    end
    
    def initialize args = Hash.new
      require 'ragol/optproc/boolean_option'
      require 'ragol/optproc/fixnum_option'
      require 'ragol/optproc/float_option'
      require 'ragol/optproc/regexp_option'
      require 'ragol/optproc/string_option'

      newargs = self.class.convert_arguments args
      
      @valuereq = newargs[:valuereq]
      
      regexps = newargs[:regexps]
      @regexps = regexps && Regexps.new([ regexps ].flatten)
      
      tags = newargs[:tags]
      @tags = tags && Tags.new(tags)
      
      opttype = newargs[:valuetype]
      clssym = TYPES_TO_CLASSES[opttype]
      optcls = if clssym
                 OptProc.const_get(clssym)
               else
                 Option
               end
      @option_class = optcls
      @default = newargs[:default]
      @process = newargs[:process]
    end
  end
end
