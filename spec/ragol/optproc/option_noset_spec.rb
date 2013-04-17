#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'
require 'ragol/optproc/common'

Logue::Log.level = Logue::Log::INFO

describe OptProc::Option do
  include_context "common optproc"

  describe "option without setter" do
    def option_data
      {
        :tags => %w{ --none },
        :arg  => [ :none ],
      }
    end

    it "should set the results field" do
      args = %w{ --none xyz }
      result = process args
      result.value('none').should be_true
    end
  end
end
