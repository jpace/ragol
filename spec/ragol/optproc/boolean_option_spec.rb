#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/boolean_option'
require 'ragol/optproc/common'
require 'spec_helper'

describe Ragol::Option do
  include_context "common optproc"

  def option_data
    {
      :tags => %w{ -f --foxtrot },
      :arg  => [ :boolean ],
      :set  => Proc.new { |val| @value = true },
      :description => "a dance",
    }      
  end

  it_behaves_like "a boolean option" do
    let(:value) { @value }
    let(:option) { OptProc::OptionSet.new([option_data]).options[0] }
  end
end
