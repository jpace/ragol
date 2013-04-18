#!/usr/bin/ruby -w
# -*- ruby -*-

module OptProc
  class OptionArguments < Hash
    VAR_TYPES = [
      :boolean,
      :string,
      :float,
      :integer,
      :fixnum,
      :regexp
    ]

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
      :takesvalue => [ true, :optional, false ],
      :valuetype => [ :boolean, :string, :float, :integer, :fixnum, :regexp ],
      :default => nil,
      :process => Proc.new { },
      :postproc => Proc.new { }
    }
    
    def self.convert_arguments origargs
      args = Hash.new
      
      if origargs[:arg]
        if valuetype = origargs[:arg].find { |x| VAR_TYPES.include?(x) }
          args[:valuetype] = valuetype == :integer ? :fixnum : valuetype
        end

        if valuetype == :boolean
          args[:takesvalue] = false
        else
          takesvalue = origargs[:arg].find { |x| [ :optional, :required, :none ].include?(x) }
          args[:takesvalue] = case takesvalue
                            when :optional
                              :optional
                            when :required
                              true
                            when :none, nil
                              valuetype != nil
                            end
        end
      else
        args[:takesvalue] = origargs[:takesvalue] || origargs[:valuereq] || false
        args[:valuetype] = origargs[:valuetype]
      end

      fields = [
                [ :regexps, :regexp, :res, :re ],
                [ :tags ],
                [ :process, :set ],
                [ :postproc ],
                [ :rcnames, :rc ],
                [ :default ],
                [ :unsets, :unset ],
               ]
      fields.each do |fieldnames|
        args[fieldnames.first] = origargs[fieldnames.find { |x| origargs[x] }]
      end
      
      args
    end
    
    def initialize args = Hash.new
      merge! self.class.convert_arguments(args)
    end
  end
end
