#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'

module Ragol
  class Matcher
    include Logue::Loggable
    
    attr_reader :tags
    
    def initialize tags
      @tags = [ tags ].flatten.compact
    end

    def find_match opt
      tag = opt.split('=', 2)[0] || opt

      @tags.each do |t|
        if t.kind_of?(Regexp)
          if md = t.match(tag)
            return [ :regexp, md ]
          end
        elsif tag.length > t.length
          next 
        elsif idx = t.index(tag)
          score = tag.length == t.length ? 1.0 : tag.length * 0.01
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
      @tags.join(', ')
    end
  end
end
