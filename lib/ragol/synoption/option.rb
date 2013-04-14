#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'ragol/synoption/doc'
require 'ragol/common/option'

module Synoption
  class Option < Ragol::Option
    include Logue::Loggable

    attr_reader :description
    attr_reader :tag

    def initialize name, tag, description, default, options = Hash.new
      @tag = tag
      @description = description
      @value = default

      tags = [ tag, '--' + name.to_s.gsub('_', '-') ]
      super name, default, tags, options[:negate], options[:regexp], options[:unsets]
    end

    def takes_value?
      true
    end
      
    def to_doc io
      doc = Doc.new self
      doc.to_doc io
    end

    def take_eq_value opt
      val = opt.split('=', 2)[1]
      val
    end

    def next_argument results
      if results.args_empty?
        raise "value expected for option: #{self}"
      end
      results.shift_arg
    end

    def set_value_for_tag results, arg
      val = if takes_value?
              take_eq_value(arg) || next_argument(results)
            else
              true
            end
      
      set_option_value results, val
    end

    def set_value_negative results, arg
      set_option_value results, false
    end

    def set_value_regexp results, arg
      md = @matchers.regexp_match? arg
      set_option_value results, md[0]
    end

    def set_option_value results, val
      results.set_value name, val
    end
  end
end
