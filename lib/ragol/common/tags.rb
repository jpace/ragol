#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'

module Ragol
  class Tags
    attr_reader :tags
    
    def initialize tags
      @tags = tags
    end

    def match? arg
      score(arg) == 1.0
    end

    def score opt
      tag = opt.split('=', 2)[0] || opt
      return unless tm = @tags.detect do |t|
        t.index(tag) == 0 && tag.length <= t.length
      end
      
      if tag.length == tm.length
        1.0
      else
        tag.length.to_f * 0.01
      end
    end

    def to_s
      @tags.join(', ')
    end
  end
end
