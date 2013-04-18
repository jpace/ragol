#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/doc'
require 'ragol/common/option'
require 'ragol/common/doc'

module Synoption
  class Option < Ragol::Option
    attr_reader :description
    attr_reader :tag

    def initialize name, tag, description, default, options = Hash.new
      @tag = tag
      @description = description
      takesvalue = if options.has_key?(:valuereq)
                     options[:valuereq]
                   else
                     true
                   end

      tags = [ tag, '--' + name.to_s.gsub('_', '-') ]
      super name, default, tags, options[:negate], options[:regexp], options[:unsets], options[:process], takesvalue
    end
      
    def to_doc io
      doc = Ragol::Doc.new self
      doc.to_doc io
    end
  end
end
