#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/tag_option'

module OptProc
  class BooleanOption < TagOption
    TRUE = %w{ yes true on }
    FALSE = %w{ no false off }
    
    REGEXP = Regexp.new('^(' + (TRUE | FALSE).join('|') + ')$', Regexp::IGNORECASE)

    def value_regexp
      nil
    end
    
    def convert_value val
      to_boolean val
    end

    def to_boolean val
      TRUE.include? val.downcase
    end
  end
end
