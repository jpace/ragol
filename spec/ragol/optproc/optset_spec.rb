#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optset'
require 'ragol/optproc/common'
require 'ragol/optproc/args'
require 'spec_helper'

describe OptProc::OptionSet do
  include OptProc::OptionTestSets
  
  include_context "common optproc"
  include_context "common optset tests"

  let(:optset) do
    optdata = option_data
    OptProc::OptionSet.new optdata
  end

  context "when one option unsets another" do
    def process args
      @results = create_abc_option_set(:unsets => 'bravo').process args
    end

    subject { @results }

    it_behaves_like "an option set with unset options"
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
        should eql '123'
      end
    end
  end

  describe "#process" do
    def option_data
      optdata = Array.new

      @context = nil
      optdata << {
        :tags => %w{ -C --context },
        :res  => %r{ ^ - ([1-9]\d*) $ }x,
        :arg  => [ :optional, :integer ],
        :set  => Proc.new { |val, opt, args| @context = val || 2 },
      }
      @abc = nil
      optdata << {
        :tags => %w{ -a --abc },
        :set  => Proc.new { |v| @abc = v }
      }
      
      optdata
    end
    
    def process args
      optset.process args
    end

    it "takes a tag argument" do
      process %w{ --context 17 }
      @context.should eq 17
    end

    it "takes a tag argument" do
      process %w{ -C 17 }
      @context.should eq 17
    end

    it "ignores missing tag argument" do
      process %w{ --context }
      @context.should eq 2
    end

    it "takes the regexp value (not argument)" do
      process %w{ -17 }
      @context.should eq 17
    end

    it "takes the regexp value with following -o" do
      args = %w{ -17 -a }
      process args
      @context.should eq 17
      @abc.should be_true
      args.should be_empty
    end
  end
end
