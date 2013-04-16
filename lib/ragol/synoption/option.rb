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
      @valuereq = if options.has_key?(:valuereq)
                    options[:valuereq]
                  else
                    true
                  end

      tags = [ tag, '--' + name.to_s.gsub('_', '-') ]
      super name, default, tags, options[:negate], options[:regexp], options[:unsets]
    end

    def takes_value?
      @valuereq
    end
      
    def to_doc io
      doc = Doc.new self
      doc.to_doc io
    end

    def set_value_negative results, arg
      set_option_value false, arg, results
    end

    def set_value_regexp results, arg
      md = @matchers.regexp_match? arg
      set_option_value md, arg, results
    end

    def set_option_value md, arg, results
      val = md == true ? true : convert(md)
      results.set_value name, val
    end
  end
end
