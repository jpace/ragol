#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optproc'

Logue::Log.level = Logue::Log::INFO

describe OptProc::RegexpOption do
  before :all do
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end

  before do
    pending "still working out the functionality"
  end

  def create_set optdata
    @set = OptProc::OptionSet.new optdata
  end

  def process args
    @set.process_option args
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

  describe "with required string argument" do
    def create_option_data optdata
      @opt_value = nil
      optdata << {
        :regexp => %r{^--(foo)}x,
        :arg    => [ :string, :required ],
        :set    => Proc.new { |val| @opt_value = val },
      }
    end

    subject { @opt_value }

    it "takes required argument" do
      process %w{ --foo xyz }
      should eq 'xyz'
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

    it "does not convert value" do
      process %w{ --xy }
      @regexp_value.should be_kind_of(MatchData)
      @regexp_value[0].should eql '--xy'
      @regexp_value[1].should eql 'xy'
    end
  end
end
