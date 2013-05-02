#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/common'
require 'spec_helper'

describe "OptProc::Option" do
  include_context "common optproc"

  describe "option with both tags and regexps" do
    def option_data
      {
        :tags => %w{ -C --context },
        :res  => %r{ ^ - ([1-9]\d*) $ }x,
        :arg  => [ :optional, :integer ],
        :set  => Proc.new { |val, opt, args| @value = val || 2 },
      }
    end

    it "takes a tag argument" do
      process %w{ --context 17 }
      value.should eq 17
      results.context.should eq 17
    end

    it "takes a tag argument" do
      process %w{ -C 17 }
      value.should eq 17
      results.context.should eq 17
    end

    it "ignores missing tag argument" do
      process %w{ --context }
      value.should eq 2
      results.context.should eq nil
    end

    it "takes the regexp value (not argument)" do
      process %w{ -17 }
      value.should eq 17
      results.context.should eq 17
    end
  end
end
