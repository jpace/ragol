#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/boolean_option'
require 'ragol/synoption/set'
require 'support/option_sets'

# Logue::Log.level = Logue::Log::INFO

describe Synoption::BooleanOption do
  include Synoption::OptionTestSets

  def create_option
    Synoption::OptionTestSets::FoxtrotOption.new
  end
  
  describe "#new" do
    subject(:option) { create_option }

    its(:name) { should eql :foxtrot }
    its(:default) { should == false }
    its(:description) { should eql 'a dance' }
  end

  describe "#process" do
    subject(:results) { @results }
    
    valid_tags = %w{ -f --foxtrot }
    
    valid_tags.each do |tag|
      context "with valid tag #{tag}" do
        before :all do
          process_option [ tag, 'foo' ]
        end
        
        its(:foxtrot) { should == true }
        its(:unprocessed) { should eql %w{ foo } }
      end
    end

    valid_tags.each do |tag|
      before :all do
        process_option [ tag, 'nextarg' ]
      end
      
      it "should not take the following argument for tag #{tag}" do
        results.unprocessed.should eql %w{ nextarg }
      end
    end
  end
end
