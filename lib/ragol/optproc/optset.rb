#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/option'
require 'ragol/option_set'
require 'ragol/optproc/args'

module OptProc
  class OptionSet < Ragol::OptionSet
    include Logue::Loggable
    
    attr_reader :options
    
    def initialize data
      options = data.collect do |optdata|
        optargs = OptionArguments.new(optdata)

        opttype = optargs[:valuetype]
        clstype = OptionArguments::VAR_TYPES[opttype]

        if clstype
          clsstr = clstype.to_s
          require 'ragol/' + clsstr + '_option'
          clssym = (clsstr.capitalize + 'Option').to_sym
          optcls = ::Ragol.const_get(clssym)
          optcls.new(optargs)
        else
          Ragol::Option.new(optargs)
        end
      end
      super(*options)
    end

    # this is a legacy method; process should be used instead.
    def process_option argslist
      set_option argslist
    end
  end
end
