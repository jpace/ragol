#!/usr/bin/ruby -w
# -*- ruby -*-

module OptProc
  class OptionValue
    def convert md
      return unless val = md && md[1]
      convert_value val
    end
  end

  class BooleanValue < OptionValue
    def convert_value val
      to_boolean val
    end

    def to_boolean val
      %w{ yes true on soitenly }.include? val.downcase
    end
  end

  class StringValue < OptionValue
    def convert_value val
      val
    end
  end

  class IntegerValue < OptionValue
    def convert_value val
      val.to_i
    end
  end

  class FloatValue < OptionValue
    def convert_value val
      val.to_f
    end
  end

  class RegexpValue < OptionValue
    # not implemented

    def convert md
      md
    end
  end
end
