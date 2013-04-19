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

    it_behaves_like "a fixnum option" do
      let(:value) { @results.delta }
    end
  end
end
