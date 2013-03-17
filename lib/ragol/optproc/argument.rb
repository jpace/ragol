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
  end

  class RequiredOptionArgument < OptionArgument
    def take_value opt, args
      val = opt.split('=', 2)[1] || args.shift
      raise MissingExpectedArgument.new unless val
      do_match val
    end
  end

  class OptionalOptionArgument < OptionArgument
    def take_next_value args
      return if args.empty? || args[0][0] == '-'
      if md = do_match(args[0])
        args.shift
        md
      end
    end

    def take_value opt, args
      if val = opt.split('=', 2)[1]
        do_match val
      else
        take_next_value args
      end
    end
  end
end
