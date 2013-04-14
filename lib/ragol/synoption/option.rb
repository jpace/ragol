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

    def next_argument results
      val = results.shift_arg
      val && do_match(val)
    end

    def set_value_for_tag results, arg
      val = if takes_value?
              take_eq_value(arg) || next_argument(results) || argument_missing
            else
              true
            end
      set_option_value val, results
    end

    def set_value_negative results, arg
      set_option_value false, results
    end

    def set_value_regexp results, arg
      md = @matchers.regexp_match? arg
      set_option_value md[0], results
    end

    def set_option_value md, results
      val = md == true ? true : convert(md)
      results.set_value name, val
    end
  end
end
