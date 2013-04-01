#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/boolean_option'
require 'ragol/synoption/set'
require 'support/option_sets'

# Logue::Log.level = Logue::Log::INFO

describe Synoption::BooleanOption do
  include Synoption::OptionTestSets
  
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
    def process args
      optset = Synoption::OptionSet.new
      optset.add Synoption::OptionTestSets::FoxtrotOption.new
      def optset.name; 'testing'; end
      @results = optset.process args
    end

    subject(:results) { @results }
    
    %w{ -f --foxtrot }.each do |tag|
      before :all do
        process [ tag ]
      end

      its(:foxtrot) { should == true }
    end

    context "does not take following argument" do
      %w{ -f --foxtrot }.each do |tag|
        before :all do
          process [ tag, 'nextarg' ]
        end

        its(:foxtrot) { should == true }
        its(:unprocessed) { should eql %w{ nextarg } }
      end
    end
  end
end
