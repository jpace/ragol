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
end
