#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/common/boolean_option'
require 'ragol/optproc/common'
require 'spec_helper'

describe OptProc::Option do
  include_context "common optproc"

  def option_data
    {
      :tags => %w{ -f --foxtrot },
      :arg  => [ :boolean ],
      :set  => Proc.new { |val| @value = true },
      :description => "a dance",
    }      
  end

  context "argument" do
    it "should default to nil" do
      opt = OptProc::Option.new option_data
      opt.default.should == nil
    end
  end

  it_behaves_like "a boolean option" do
    let(:value) { @value }
    let(:option) { OptProc::Option.new option_data }
  end
end
