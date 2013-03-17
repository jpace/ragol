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

  class StringValue < OptionValue
    REGEXP = %r{^ [\"\']? (.*?) [\"\']? $ }x
    
    def convert_value val
      val
    end
  end

  class IntegerValue < OptionValue
    REGEXP = %r{^ ([\-\+]?\d+) $ }x
    
    def convert_value val
      val.to_i
    end
  end

  class FloatValue < OptionValue
    REGEXP = %r{^ ([\-\+]?\d* (?:\.\d+)?) $ }x
    
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

  ARG_TYPES = Hash.new
  [ IntegerValue, FloatValue, StringValue, BooleanValue ].each do |cls|
    sym = cls.to_s.sub(%r{^.*::}, '').sub(%r{Value$}, '').downcase.intern
    ARG_TYPES[sym] = [ cls.const_get('REGEXP'), cls ]
  end
end
