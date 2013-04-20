#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/args'
require 'ragol/common/option'

module OptProc
  class Option < Ragol::Option
    include Logue::Loggable

    class << self
      alias_method :old_new, :new
      def new(*args, &blk)
        optargs = OptionArguments.new(*args)
        optargs[:process] = blk if blk

        opttype = optargs[:valuetype]
        clstype = OptionArguments::VAR_TYPES[opttype]

        if clstype == :fixnum
          require 'ragol/common/fixnum_option'
          return Ragol::FixnumOption.new(optargs)
        elsif clstype == :boolean
          require 'ragol/common/boolean_option'
          return Ragol::BooleanOption.new(optargs)
        elsif clstype == :float
          require 'ragol/common/float_option'
          return Ragol::FloatOption.new(optargs)
        elsif clstype == :regexp
          require 'ragol/common/regexp_option'
          return Ragol::RegexpOption.new(optargs)
        end

        optcls = if clstype
                   clsstr = clstype.to_s
                   'ragol/optproc/' + clsstr + '_option'
                   clssym = (clsstr.capitalize + 'Option').to_sym
                   OptProc.const_get(clssym)
                 else
                   Option
                 end

        optcls.old_new(optargs)
      end
    end
  end
end
