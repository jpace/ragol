#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/float_option'
require 'ragol/synoption/optset'
require 'support/so_option_sets'
require 'spec_helper'

describe Synoption::FloatOption do
  include Synoption::OptionTestSets

  def create_option
    Synoption::OptionTestSets::HotelOption.new
  end
  
  describe "#new" do
    subject(:option) { create_option }

    its(:name) { should eql :hotel }
    its(:default) { should eql 8.79 }
    its(:description) { should eql 'an upscale motel' }
  end

  subject(:results) { @results }
  
  it_behaves_like "a float option" do
    let(:value) { @results.hotel }
  end
end
