#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/option'
require 'ragol/optproc/common'
require 'spec_helper'

describe Ragol::Option do
  include_context "common optproc"

  describe "option with argument :none" do
    def option_data
      {
        :tags => %w{ --none },
        :arg  => [ :none ],
        :set  => Proc.new { |x| @value = 'wasset' }
      }
    end

    it "can take :none as argument" do
      args = %w{ --none xyz }
      process args
      value.should eql 'wasset'
      args.should have(1).items
      results.none.should be_true
    end
  end
end
