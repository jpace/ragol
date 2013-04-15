#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'
require 'ragol/optproc/common'

Logue::Log.level = Logue::Log::INFO

describe OptProc::Option do
  include_context "common option"

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
      should eq 'abc'
    end

    it "takes an argument with equals" do
      process %w{ --xyz=abc }
      should eq 'abc'
    end
  end
end
