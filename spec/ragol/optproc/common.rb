#!/usr/bin/ruby -w
# -*- ruby -*-

shared_context "common option" do
  before :all do
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end

  subject { @value }

  let(:option) { OptProc::Option.new option_data }
  
  def process args
    option.set_value args
  end
end
