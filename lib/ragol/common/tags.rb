#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'

module Ragol
  class Tags
    include Logue::Loggable
    
    attr_reader :tags
    
    def initialize tags
      @tags = tags
    end

    def match? arg
      score(arg) == 1.0
    end

    def score opt
      tag = opt.split('=', 2)[0] || opt

      @tags.each do |t|
        if t.kind_of?(Regexp)
          return 1.0 if t.match(tag)
        elsif tag.length > t.length
          next 
        elsif idx = t.index(tag)
          return 1.0 if tag.length == t.length
          return tag.length * 0.01
        end
      end
      nil
    end

    def to_s
      @tags.join(', ')
    end
  end
end
