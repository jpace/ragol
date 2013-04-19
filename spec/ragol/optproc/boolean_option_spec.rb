#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/boolean_option'
require 'ragol/optproc/common'
require 'spec_helper'

describe OptProc::BooleanOption do
  include_context "common optproc"

  context "argument" do
    def option_data
      {
        :tags => %w{ --bool },
        :arg  => [ :boolean ],
        :set  => Proc.new { |val| @value = true },
        :description => "this is something",
      }      
    end

    it "should default to nil" do
      opt = OptProc::Option.new option_data
      opt.default.should == nil
    end

    it "should be true" do
      process [ '--bool' ]
      should eq true
    end
    
    it "should be true" do
      args = %w{ --bool foo }
      process args
      should eq true
      args.size.should == 1
    end

    it "should have documentation" do
      opt = OptProc::Option.new option_data
      sio = StringIO.new
      opt.to_doc sio
      exp = String.new
      exp << "  --bool                   : this is something\n"
      sio.string.should eql exp
    end
  end
end
