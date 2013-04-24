#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'
require 'ragol/optproc/common'
require 'spec_helper'

describe OptProc::Option do
  include_context "common optproc"

  describe "option without argument type" do
    def option_data
      {
        :tags => %w{ --undefn },
        :set  => Proc.new { |x| @value = 'setitwas' }
      }
    end

    it "defaults to :none" do
      args = %w{ --undefn xyz }
      process args
      @value.should eql 'setitwas'
      args.should have(1).items
      results.undefn.should be_true
    end
  end
end
