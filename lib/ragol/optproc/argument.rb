#!/usr/bin/ruby -w
# -*- ruby -*-

module OptProc
  class OptionArgument
    def initialize tags, valuere
      @tags = tags
      @valuere = valuere
    end

    def do_match val
      if @valuere
        unless md = @valuere.match(val)
          raise "invalid argument '#{val}' for option: #{@tags}"
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
      raise "value expected for option: #{@tags}" unless val
      do_match val
    end
  end

  class OptionalOptionArgument < OptionArgument
    def take_value opt, args
      val = opt.split('=', 2)[1]

      if val
        do_match(val)
      elsif args.size > 0
        if %r{^-}.match args[0]
          # skipping next value; apparently option
          nil
        elsif md = do_match(args[0])
          args.shift
          md
        end
      else
        nil
      end
    end
  end
end
