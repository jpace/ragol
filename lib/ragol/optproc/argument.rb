#!/usr/bin/ruby -w
# -*- ruby -*-

module OptProc
  class InvalidArgument < RuntimeError
    attr_reader :value
    
    def initialize value
      @value = value
    end
  end

  class MissingExpectedArgument < RuntimeError
  end

  class OptionArgument
    def initialize valuere
      @valuere = valuere
    end

    def do_match val
      if @valuere
        unless md = @valuere.match(val)
          raise InvalidArgument.new val
        end
        md
      else
        val
      end
    end

    def take_eq_value opt
      val = opt.split('=', 2)[1]
      val && do_match(val)
    end

    def take_value opt, args
      take_eq_value(opt) || match_next_value(args) || argument_missing
    end
  end

  class RequiredOptionArgument < OptionArgument
    def match_next_value args
      val = args.shift
      val && do_match(val)
    end

    def argument_missing
      raise MissingExpectedArgument.new
    end
  end

  class OptionalOptionArgument < OptionArgument
    def match_next_value args
      return unless val = args.shift
      
      if val[0] == '-'
        args.unshift val
        nil
      else
        do_match val
      end
    end

    def argument_missing
    end
  end
end
