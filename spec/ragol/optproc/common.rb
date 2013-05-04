#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optset'

shared_context "common optproc" do
  let(:value) { @value }
  let(:results) { @results }

  def process args
    optset = OptProc::OptionSet.new [ option_data ]
    @results = optset.process args
  end
  
  def process_option args
    optset = OptProc::OptionSet.new [ option_data ]
    @results = optset.process args
  end
end
