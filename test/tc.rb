#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'stringio'
require 'test/unit'

Logue::Log.level = Logue::Log::INFO
Logue::Log.set_widths(-35, 4, -35)

module Synoption
  class TestCase < Test::Unit::TestCase
    include Logue::Loggable
    
    def setup
    end
    
    def test_truth
      assert true
    end
  end
end
