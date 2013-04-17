#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optproc'
require 'ragol/common'

describe "regexp option" do
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

  describe "with integer type" do
    def create_option_data optdata
      @integer_value = nil
      optdata << {
        :regexp => %r{ ^ - (1\d*) $ }x,
        :arg    => [ :integer ],
        :set    => Proc.new { |val| @integer_value = val },
      }
    end

    subject { @integer_value }

    it "converts value" do
      process %w{ -123 }
      should eq 123
    end
  end

  describe "with string type" do
    def create_option_data optdata
      @string_value = nil
      optdata << {
        :regexp => %r{ ^ - (2\d*) $ }x,
        :arg    => [ :string ],
        :set    => Proc.new { |val| @string_value = val },
      }
    end

    subject { @string_value }

    it "converts value" do
      process %w{ -234 }
      should eq '234'
    end
  end

  describe "with no argument type" do
    def create_option_data optdata
      @regexp_value = nil
      optdata << {
        :regexp => %r{ ^ -- (x[yz]+) $ }x,
        :set    => Proc.new { |val| @regexp_value = val },
      }
    end

    it "should return the last capture" do
      process %w{ --xy }
      @regexp_value.should eql 'xy'
    end
  end
end
