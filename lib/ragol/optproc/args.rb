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
      :postproc => Proc.new { |optset, results, unprocessed| },
      :description => "a description"
    }
    
    def initialize origargs = Hash.new
      super()

      if origargs[:arg]
        self[:valuetype] = Ragol::HashUtil.hash_array_value VAR_TYPES, origargs[:arg]
        self[:takesvalue] = if self[:valuetype] == :boolean
                              false
                            else
                              hasvaluetype = self[:valuetype] != nil
                              takes = { :optional => :optional, :required => true, :none => hasvaluetype, nil => hasvaluetype }
                              Ragol::HashUtil.hash_array_value takes, origargs[:arg]
                            end
      else
        Ragol::HashUtil.copy_hash self, origargs, [ [ :takesvalue, :valuereq ], [ :valuetype ] ]
      end

      fields = [
                [ :regexps, :regexp, :res, :re ],
                [ :tags ],
                [ :process, :set ],
                [ :postproc ],
                [ :rcnames, :rc ],
                [ :default ],
                [ :unsets, :unset ],
                [ :description ],
               ]
      Ragol::HashUtil.copy_hash self, origargs, fields
    end
  end
end
