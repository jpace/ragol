#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optset'

shared_context "ragol common optproc" do
  let(:value) { @value }
  let(:results) { @results }

  def process args
    optset = Ragol::OptionSet.new :data => [ option_data ]
    @results = optset.process args
  end
  
  def process_option args
    optset = Ragol::OptionSet.new :data => [ option_data ]
    @results = optset.process args
  end
end
