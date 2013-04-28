#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optproc'

describe "regexp value option" do
  def create_set optdata
    @optset = OptProc::OptionSet.new optdata
  end

  def process args
    @optset.process args
  end

  before do
    optdata = Array.new
    create_option_data optdata
    create_set optdata
  end

  describe "#process" do
    def create_option_data optdata
      @value = nil
      optdata << {
        :tags => %w{ -u --highlight },
        :arg  => [ :optional, :regexp, %r{^(multi|single|none)$} ],
        :set  => Proc.new { |val| @value = val || true },
      }
    end

    subject { @value }

    it "should set from -u" do
      process %w{ -u }
      should eql true
    end

    it "should set from --highlight" do
      process %w{ --highlight }
      should eql true
    end

    it "should set from --highlight multi" do
      process %w{ --highlight multi }
      should eql 'multi'
    end
  end
end
