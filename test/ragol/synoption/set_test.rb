#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'ragol/synoption/set'
require 'ragol/synoption/option'

module Synoption
  class SetTestCase < TestCase
    class TestOptionSet < OptionSet
      def name
        'test'
      end
    end

    def setup
      @xyz = Option.new :xyz, '-x', "blah blah xyz",    nil
      @abc = Option.new :abc, '-a', "abc yadda yadda",  nil
      @tnt = Option.new :tnt, '-t', "tnt and so forth", nil
      
      @optset = TestOptionSet.new [ @xyz, @abc, @tnt ]
    end

    def test_find_by_name
      assert_not_nil @optset.find_by_name(:xyz)
      assert_nil @optset.find_by_name(:bfd)
    end

    def test_process_set
      @optset.process %w{ -x foo }
      
      assert_equal 'foo', @xyz.value
    end

    def test_process_not_set
      @optset.process %w{ -x foo }
      
      assert_nil @abc.value
      assert_nil @tnt.value
    end

    def test_bad_option
      assert_raises(OptionException) do
        @optset.process %w{ -y foo }
      end
    end

    def test_stop_on_double_dash
      @optset.process %w{ -- -x foo }
      
      assert_nil @xyz.value
      assert_nil @abc.value
      assert_nil @tnt.value
    end
  end
end
