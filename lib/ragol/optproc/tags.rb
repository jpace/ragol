#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module OptProc
  class Tags
    def initialize tags = Array.new
      @tags = tags
    end

    def match_tag_score opt
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
  end
end
