#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/common/tags'

module OptProc
  class OptionArguments
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
      :set => Proc.new { },
      :rcnames => [ "foo" ],
      :rc => [ ]
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
    
    def self.convert_arguments origargs
      args = Hash.new
      
      if origargs[:arg]
        if valuetype = origargs[:arg].find { |x| TYPES_TO_CLASSES.keys.include?(x) }
          args[:valuetype] = valuetype == :integer ? :fixnum : valuetype
        end

        if valuetype == :boolean
          args[:valuereq] = false
        else
          valuereq = origargs[:arg].find { |x| [ :optional, :required, :none ].include?(x) }
          args[:valuereq] = case valuereq
                            when :optional
                              :optional
                            when :required
                              true
                            when :none, nil
                              valuetype != nil
                            end
        end
      else
        args[:valuereq] = origargs[:valuereq] || false
        args[:valuetype] = origargs[:valuetype]
      end

      fields = [
                [ :regexps, :regexp, :res, :re ],
                [ :tags ],
                [ :process, :set ],
                [ :postproc ],
                [ :rcnames, :rc ],
                [ :default ]
               ]
      fields.each do |fieldnames|
        args[fieldnames.first] = origargs[fieldnames.find { |x| origargs[x] }]
      end
      
      args
    end
    
    def initialize args = Hash.new
      require 'ragol/optproc/boolean_option'
      require 'ragol/optproc/fixnum_option'
      require 'ragol/optproc/float_option'
      require 'ragol/optproc/regexp_option'
      require 'ragol/optproc/string_option'

      newargs = self.class.convert_arguments args

      @rcnames = newargs[:rcnames]
      @valuereq = newargs[:valuereq]
      
      regexps = newargs[:regexps]
      @regexps = regexps && Ragol::Tags.new(regexps)
      
      tags = newargs[:tags]
      @tags = tags && Ragol::Tags.new(tags)
      
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
