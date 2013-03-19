#!/usr/bin/ruby -w
# -*- ruby -*-

module OptProc
  class OptionType
    def convert md
      return unless val = md && md[1]
      convert_value val
    end
  end

  class BooleanType < OptionType
    TRUE = %w{ yes true on }
    FALSE = %w{ no false off }
    
    REGEXP = Regexp.new('^(' + (TRUE | FALSE).join('|') + ')$', Regexp::IGNORECASE)
    
    def convert_value val
      to_boolean val
    end

    def to_boolean val
      TRUE.include? val.downcase
    end
  end

  class StringType < OptionType
    REGEXP = %r{^ [\"\']? (.*?) [\"\']? $ }x
    
    def convert_value val
      val
    end
  end

  class IntegerType < OptionType
    REGEXP = %r{^ ([\-\+]?\d+) $ }x
    
    def convert_value val
      val.to_i
    end
  end

  class FloatType < OptionType
    REGEXP = %r{^ ([\-\+]?\d* (?:\.\d+)?) $ }x
    
    def convert_value val
      val.to_f
    end
  end

  class RegexpType < OptionType
    # not implemented
    def convert md
      md
    end
  end

  ARG_TYPES = Hash.new
  [ IntegerType, FloatType, StringType, BooleanType ].each do |cls|
    sym = cls.to_s.sub(%r{^.*::}, '').sub(%r{Type$}, '').downcase.intern
    ARG_TYPES[sym] = cls
  end
end
