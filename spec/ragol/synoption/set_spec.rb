#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/set'
require 'ragol/synoption/option'

Logue::Log.level = Logue::Log::INFO

describe Synoption::OptionSet do
  before do
    @xyz = Synoption::Option.new :xyz, '-x', "blah blah xyz",    nil
    @abc = Synoption::Option.new :abc, '-a', "abc yadda yadda",  nil
    @tnt = Synoption::Option.new :tnt, '-t', "tnt and so forth", nil
    
    @optset = Synoption::OptionSet.new [ @xyz, @abc, @tnt ]
    def @optset.name; 'testing'; end
  end

  describe "find by name" do
    it { @optset.find_by_name(:xyz).should be_true }
    it { @optset.find_by_name(:bfd).should be_nil }
  end

  describe "process" do
    context "valid arguments" do
      before do
        @optset.process %w{ -x foo }
      end
      
      it "sets an option" do
        @xyz.value.should eql 'foo'
      end
      
      it "ignores other options" do
        @abc.value.should be_nil
        @tnt.value.should be_nil
      end
    end

    context "invalid arguments" do
      it "throws error for bad option" do
        expect { @optset.process %w{ -y foo } }.to raise_error(Synoption::OptionException, "error: option: -y invalid for testing")
      end
    end

    context "stops on double dash" do
      before do
        @optset.process %w{ -a abc -- -x foo }
      end

      it "sets option preceding --" do
        @abc.value.should eql 'abc'
      end

      it "ignores other option" do
        @tnt.value.should be_nil
      end

      it "ignored option following --" do
        @xyz.value.should be_nil
      end
    end
  end
end
