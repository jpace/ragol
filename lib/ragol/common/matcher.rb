#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'

module Ragol
  class Matcher
    include Logue::Loggable
    
    attr_reader :elements
    
    def initialize tags
      @elements = [ tags ].flatten.compact
    end

    def find_match opt
      tag = opt.split('=', 2)[0] || opt

      @elements.each do |elmt|
        if elmt.kind_of?(Regexp)
          if md = elmt.match(tag)
            return [ :regexp, md ]
          end
        elsif tag.length > elmt.length
          next 
        elsif idx = elmt.index(tag)
          score = tag.length == elmt.length ? 1.0 : tag.length * 0.01
          return [ :string, score ]
        end
      end
      nil
    end

    def match? opt
      type, val = find_match(opt)
      type && val
    end

    def score opt
      type, val = find_match(opt)
      type && (type == :regexp ? 1.0 : val)
   end

    def to_s
      @elements.join(', ')
    end
  end
end
