#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optset'
require 'ragol/common'
require 'spec_helper'

describe Ragol::OptionSet do
  include Ragol::OptionTestSets
  
  include_context "ragol common optproc"
  include_context "common optset tests"
  it_behaves_like "a ragol option set"

  let(:optset) do
    optdata = option_data
    Ragol::OptionSet.new :data => optdata
  end

  def process args
    optset.process args
  end
end
