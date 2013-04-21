#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optset'
require 'ragol/common'
require 'ragol/optproc/common'
require 'ragol/optproc/args'
require 'spec_helper'

describe OptProc::OptionSet do
  include OptProc::OptionTestSets
  
  include_context "common optproc"

  let(:optset) do
    optdata = option_data
    OptProc::OptionSet.new optdata
  end

  describe "#method" do
    describe "OptionSet class (not subclass)" do
      subject { create_abc_option_set.process Array.new }

      valid_methods = [ :alpha, :bravo, :charlie ]
      invalid_methods = [ :bfd ]
      
      it_behaves_like "defined methods", valid_methods, invalid_methods
    end
  end

  context "when options are isolated" do
    def process args
      @results = create_abc_option_set.process args
    end

    subject(:results) { @results }

    it_behaves_like "an option set"
  end

  context "when options contain short arguments" do
    def process args
      @results = create_fij_option_set.process args
    end
    
    subject { @results }
    
    it_behaves_like "an option set with short arguments"
  end

  context "when one option unsets another" do
    def process args
      @results = create_abc_option_set(:unsets => 'bravo').process args
    end

    subject { @results }

    it_behaves_like "an option set with unset options"
  end

  context "when options partially match" do
    def process args
      optdata = Array.new
      @delta = nil
      optdata << {
        :tags => %w{ -d --delta },
        :default => 314,
        :valuetype => :fixnum,
        :process => Proc.new { |v| @delta = v }
      }
      @delay = nil
      optdata << {
        :tags => %w{ -y --delay },
        :valuetype => :string,
        :process => Proc.new { |v| @delay = v }
      }
      @results = OptProc::OptionSet.new(optdata).process args
    end

    subject { @results }

    it_behaves_like "an option set with partially matching options"
  end

  describe "#process" do
    def process args
      optset.process args
    end

    context "when regexp" do
      def option_data
        @value = nil
        optdata = Array.new
        optdata << {
          :res => %r{ ^ - ([1-9]\d*) $ }x,
          :set => Proc.new { |val| @value = val },
        }
        optdata
      end

      subject { @value }

      it "should match" do
        args = %w{ -123 }
        process args
        subject.should eql '123'
      end
    end
  end

  describe "#process" do
    def option_data
      @strval = nil
      optdata = Array.new
      optdata << {
        :tags => %w{ --sopt },
        :arg  => [ :string, :optional ],
        :set  => Proc.new { |v| @strval = v }
      }
      
      add_abc_opt optdata
      optdata
    end
    
    def process args
      optset.process args
    end

    it "takes an argument" do
      process %w{ --sopt xyz }
      @strval.should eq 'xyz'
      abc.should be_false
    end

    it "takes an argument with =" do
      process %w{ --sopt=xyz }
      @strval.should eq 'xyz'
      abc.should be_false
    end

    it "ignores a missing argument" do
      process %w{ --sopt }
      @strval.should be_nil
    end

    it "ignores a following --abc option" do
      args = %w{ --sopt --abc }
      process args
      @strval.should be_true
      abc.should be_true
      args.should be_empty
    end

    it "ignores a following -a option" do
      args = %w{ --sopt -a }
      process args
      @strval.should be_true
      abc.should be_true
      args.should be_empty
    end
  end

  describe "#process" do
    def option_data
      @reval = nil
      optdata = Array.new
      optdata << {
        :tags => %w{ -C --context },
        :res  => %r{ ^ - ([1-9]\d*) $ }x,
        :arg  => [ :optional, :integer ],
        :set  => Proc.new { |val, opt, args| @reval = val || 2 },
      }
      
      add_abc_opt optdata
      optdata
    end
    
    def process args
      optset.process args
    end

    it "takes a tag argument" do
      process %w{ --context 17 }
      @reval.should eq 17
    end

    it "takes a tag argument" do
      process %w{ -C 17 }
      @reval.should eq 17
    end

    it "ignores missing tag argument" do
      process %w{ --context }
      @reval.should eq 2
    end

    it "takes the regexp value (not argument)" do
      process %w{ -17 }
      @reval.should eq 17
    end

    it "takes the regexp value with following -o" do
      args = %w{ -17 -a }
      process args
      @reval.should eq 17
      abc.should be_true
      args.should be_empty
    end
  end
end
