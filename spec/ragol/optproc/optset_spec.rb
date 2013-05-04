#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optset'
require 'ragol/optproc/common'
require 'spec_helper'

describe OptProc::OptionSet do
  include OptProc::OptionTestSets
  
  include_context "common optproc"
  include_context "common optset tests"
  it_behaves_like "a ragol option set"

  let(:optset) do
    optdata = option_data
    OptProc::OptionSet.new optdata
  end

  def process args
    optset.process args
  end
end
