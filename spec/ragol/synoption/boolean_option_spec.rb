#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/boolean_option'
require 'ragol/synoption/set'
require 'support/option_sets'
require 'spec_helper'

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

  subject(:results) { @results }
  
  it_behaves_like "a boolean option" do
    let(:value) { @results.foxtrot }
    let(:option) { create_option }
  end
end
