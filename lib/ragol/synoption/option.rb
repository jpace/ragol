#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/common/option'

module Synoption
  class Option < Ragol::Option
    attr_reader :description

    def initialize name, tag, description, default, options = Hash.new
      @description = description
      takesvalue = if options.has_key?(:takesvalue)
                     options[:takesvalue]
                   else
                     true
                   end

      optargs = options.dup
      optargs[:takesvalue] = takesvalue
      optargs[:regexps] ||= options[:regexp]
      optargs[:negates] ||= options[:negate]
      optargs[:tags] = [ tag, '--' + name.to_s.gsub('_', '-') ]
      
      super name, default, optargs
    end
  end
end
