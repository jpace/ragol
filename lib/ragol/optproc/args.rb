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

    def self.convert_value_type args, valueargs
      args[:valuetype] = Ragol::HashUtil.hash_array_value VAR_TYPES, valueargs
      args[:takesvalue] = if args[:valuetype] == :boolean
                            false
                          else
                            hasvaluetype = args[:valuetype] != nil
                            takes = { :optional => :optional, :required => true, :none => hasvaluetype, nil => hasvaluetype }
                            Ragol::HashUtil.hash_array_value takes, valueargs
                          end
    end
    
    def self.convert_arguments origargs
      args = Hash.new
      
      if origargs[:arg]
        convert_value_type args, origargs[:arg]
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
    
    def initialize args = Hash.new
      super()
      merge! self.class.convert_arguments(args)
    end
  end
end
