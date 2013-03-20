#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/optproc/option'
require 'ragol/optproc/type'
require 'ragol/optproc/argument'

module OptProc
  class TagOption < Option
    attr_reader :tags
    
    def initialize args = Hash.new, &blk
      @tags = args[:tags] || Array.new
      super
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

    def take_value opt, args
      begin
        @optarg && @optarg.take_value(opt, args)
      rescue InvalidArgument => e
        raise "invalid argument '#{e.value}' for option: #{@tags.join(', ')}"
      rescue MissingExpectedArgument => e
        raise "value expected for option: #{@tags.join(', ')}"
      end
    end
  end
end
