#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'
require 'ragol/optproc/common'

Logue::Log.level = Logue::Log::INFO

describe OptProc::Option do
  include_context "common option"

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
      should eql 'setitwas'
      args.should have(1).items
    end
  end
end
