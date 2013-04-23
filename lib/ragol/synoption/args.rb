#!/usr/bin/ruby -w
# -*- ruby -*-

module Synoption
  class OptionArguments < Hash
    def initialize name, tag, description, default, origargs
      super()

      merge! origargs.dup
      
      takesvalue = if origargs.has_key?(:takesvalue)
                     origargs[:takesvalue]
                   else
                     true
                   end

      self[:takesvalue] = takesvalue
      self[:regexps] ||= origargs[:regexp]
      self[:negates] ||= origargs[:negate]
      self[:tags] = [ tag, '--' + name.to_s.gsub('_', '-') ]
      self[:description] = description
      self[:name] = name
      self[:default] = default
    end
  end
end
