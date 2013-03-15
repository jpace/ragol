#!/usr/bin/ruby -w
# -*- ruby -*-

module OptProc
  class OptionTags
    attr_reader :tags

    def initialize tags
      @tags = tags
    end

    def match_score tag
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
      @tags.join ', '
    end
  end
end
