#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/common/hash'

module OptProc
  class OptionArguments < Hash
    VAR_TYPES = {
      :boolean => :boolean,
      :string => :string,
      :float => :float,
      :integer => :fixnum,
      :fixnum => :fixnum,
      :regexp => :regexp,
    }

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
      :process => Proc.new { |val| },
      :postproc => Proc.new { |optset, results, unprocessed| }
    }
    
    def self.convert_arguments origargs
      args = Hash.new
      
      if origargs[:arg]
        if valuetype = origargs[:arg].find { |x| VAR_TYPES.keys.include?(x) }
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
        Ragol::HashUtil.copy_hash args, origargs, [ [ :takesvalue, :valuereq ], [ :valuetype ] ]
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
      Ragol::HashUtil.copy_hash args, origargs, fields
      
      args
    end

    def self.convert_value_type to_hash, from_hash
    end
    
    def initialize args = Hash.new
      merge! self.class.convert_arguments(args)
    end
  end
end
