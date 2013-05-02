#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/common'
require 'spec_helper'

describe "OptProc::Option" do
  include_context "common optproc"

  describe "option with required argument, without type" do
    def option_data
      {
        :tags => %w{ --xyz },
        :arg  => [ :required ],
        :set  => Proc.new { |v| @value = v }
      }
    end

    it "takes an argument" do
      process %w{ --xyz abc }
      value.should eq 'abc'
      results.xyz.should eq 'abc'
    end

    it "takes an argument with equals" do
      process %w{ --xyz=abc }
      value.should eq 'abc'
      results.xyz.should eq 'abc'
    end
  end
end
