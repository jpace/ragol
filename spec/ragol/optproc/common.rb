#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/common/argslist'
require 'ragol/optproc/optset'

shared_context "common option" do
  before :all do
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end

  subject { @value }

  let(:option) { OptProc::Option.new option_data }
  
  def process args
    optset = OptProc::OptionSet.new [ option_data ]
    optset.process args
  end
end
