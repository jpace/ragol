#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/common'
require 'spec_helper'

describe "OptProc::Option" do
  include_context "common optproc"

  context "argument" do
    def option_data
      {
        :tags => %w{ -h --hotel },
        :arg  => [ :float ],
        :set  => Proc.new { |val| @value = val }
      }
    end

    it_behaves_like "a float option" do
      let(:value) { @value }
    end
  end
end
