#!/usr/bin/ruby -w
# -*- ruby -*-

module Ragol
  class ArgsList
    attr_accessor :args
    
    def initialize args = Array.new
      @args = args
    end

    def next_arg
      curr = @args.shift
      re = Regexp.new('^-(?:(\d+)(\D)|([a-zA-Z])(\w+))')
      if md = re.match(curr)
        mi = md[1] ? 1 : 3
        arg, newarg = ('-' + md[mi]), ('-' + md[mi + 1])
        @args.unshift newarg
        arg
      else
        curr
      end
    end

    def shift_arg
      @args.shift
    end

    def args_empty?
      @args.empty?
    end

    def empty?
      @args.empty?
    end

    def current_arg
      curr = @args[0]
      re = Regexp.new('^-(?:\d+|\w)')
      if md = re.match(curr)
        md[0]
      else
        curr
      end
    end

    def eql? args
      @args == args
    end

    def [] idx
      @args[idx]
    end
  end
end
