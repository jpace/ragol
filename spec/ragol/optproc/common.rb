#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optset'

shared_context "common optproc" do
  subject { @value }

  def process args
    optset = OptProc::OptionSet.new [ option_data ]
    optset.process args
  end
  
  def process_option args
    optset = OptProc::OptionSet.new [ option_data ]
    @results = optset.process args
  end
end
