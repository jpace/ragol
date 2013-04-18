#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/fixnum_option'
require 'ragol/synoption/set'
require 'support/option_sets'

Logue::Log.level = Logue::Log::INFO

describe Synoption::FixnumOption do
  include Synoption::OptionTestSets

  def create_option
    Synoption::OptionTestSets::DeltaOption.new
  end
  
  describe "#new" do
    subject(:option) { create_option }

    its(:name) { should eql :delta }
    its(:default) { should eql 317 }
    its(:description) { should eql 'mouth of a river' }
  end

  describe "#process" do
    subject(:results) { @results }

    valid_tags = %w{ -d --delta }
    
    valid_tags.each do |tag|
      context "with valid tag #{tag}" do
        before :all do
          process_option [ tag, '434' ]
        end

        its(:delta) { should == 434 }
        its(:unprocessed) { should be_empty }
      end
    end

    valid_tags.each do |tag|
      it "raises error without required argument for tag #{tag}" do
        args = [ tag ]
        expect { process_option(args) }.to raise_error(RuntimeError, "value expected for option: -d, --delta")
      end

      it "rejects a non-integer" do
        args = [ tag, '1.0' ]
        expect { process_option(args) }.to raise_error(RuntimeError, "invalid argument '1.0' for option: -d, --delta")
        should be_nil
      end
    end

    it "rejects a non-integer as =" do
      args = %w{ --delta=1.0 }
      expect { process_option(args) }.to raise_error(RuntimeError, "invalid argument '1.0' for option: -d, --delta")
      should be_nil
    end
  end
end
