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
    subject(:option) do
      Synoption::OptionTestSets::FoxtrotOption.new
    end

    its(:name) { should eql :foxtrot }
    its(:tag) { should eql '-f' }
    its(:value) { should == false }
    its(:description) { should eql 'a dance' }
  end

  describe "#process" do
    subject(:results) { @results }
    
    %w{ -f --foxtrot }.each do |tag|
      before :all do
        process_option [ tag ]
      end

      its(:foxtrot) { should == true }
    end

    context  do
      %w{ -f --foxtrot }.each do |tag|
        before :all do
          process_option [ tag, 'nextarg' ]
        end

        it "should not take the following argument" do
          results.unprocessed.should eql %w{ nextarg }
        end
      end
    end
  end
end
