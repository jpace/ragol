#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/optproc/option'
require 'ragol/optproc/type'
require 'ragol/optproc/argument'
require 'ragol/optproc/tags'

module OptProc
  class TagOption < Option
    attr_reader :tags
    
    def initialize(*args, &blk)
      optargs = args[0]
      @tags = Tags.new(optargs[:tags] || Array.new)
      optargcls = optargs[:reqtype]
      # @optarg = optargcls && optargcls.new(optargs[:value_regexp])
      super
    end

    def match_tag_score opt
      return @tags.match_tag_score opt
    end

    def take_value opt, args
      begin
        @optarg && @optarg.take_value(opt, args)
      rescue InvalidArgument => e
        raise "invalid argument '#{e.value}' for option: #{@tags}"
      rescue MissingExpectedArgument => e
        raise "value expected for option: #{@tags}"
      end
    end
  end
end
