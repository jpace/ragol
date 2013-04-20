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

        return super(optargs) unless clstype

        clsstr = clstype.to_s
        require 'ragol/common/' + clsstr + '_option'
        clssym = (clsstr.capitalize + 'Option').to_sym
        optcls = ::Ragol.const_get(clssym)
        optcls.new(optargs)
      end
    end
  end
end
