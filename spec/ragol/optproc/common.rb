#!/usr/bin/ruby -w
# -*- ruby -*-

shared_context "common option" do
  before :all do
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end

  subject { @value }

  before do
    @value = nil
    optdata = option_data
    @option = OptProc::Option.new optdata
  end
  
  def process args
    @option.set_value args
  end
end
