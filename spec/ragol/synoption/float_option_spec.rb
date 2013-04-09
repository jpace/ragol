#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/float_option'
require 'ragol/synoption/set'
require 'support/option_sets'

# Logue::Log.level = Logue::Log::INFO

describe Synoption::FloatOption do
  include Synoption::OptionTestSets

  def create_option
    Synoption::OptionTestSets::HotelOption.new
  end
  
  describe "#new" do
    subject(:option) { create_option }

    its(:name) { should eql :hotel }
    its(:tag) { should eql '-h' }
    its(:default) { should eql 8.79 }
    its(:description) { should eql 'an upscale motel' }
  end

  describe "#process" do
    subject(:results) { @results }

    valid_tags = %w{ -h --hotel }
    
    valid_tags.each do |tag|
      context "with valid tag #{tag}" do
        before :all do
          process_option [ tag, '21.34' ]
        end

        its(:hotel) { should == 21.34 }
        it "should have no remaining arguments" do
          subject.unprocessed.should be_empty
        end
      end
    end

    valid_tags.each do |tag|
      it "raises error without required argument for tag #{tag}" do
        args = [ tag ]
        expect { process_option(args) }.to raise_error(RuntimeError, "option hotel expects following argument")
      end
    end
  end
end
