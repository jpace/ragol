#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/string_option'
require 'ragol/optproc/common'

Logue::Log.level = Logue::Log::INFO

describe OptProc::StringOption do
  include_context "common option"

  context "argument" do
    describe "required (implicit)" do
      def option_data
        {
          :tags => %w{ --str },
          :arg  => [ :string ],
          :set  => Proc.new { |v| @value = v }
        }
      end
      
      it "takes an argument" do
        process %w{ --str xyz }
        should eq 'xyz'
      end

      it "takes an argument with =" do
        process %w{ --str=xyz }
        should eq 'xyz'
      end

      it "takes an argument matching tag" do
        process %w{ --str -foo }
        should eq '-foo'
      end

      it "expects an argument" do
        args = %w{ --str }
        expect { process args }.to raise_error(RuntimeError, "value expected for option: --str")
      end
    end

    describe "required (explicit)" do
      def option_data
        {
          :tags => %w{ --str },
          :arg  => [ :string, :required ],
          :set  => Proc.new { |x| @value = x }
        }
      end
      
      it "takes the argument" do
        args = %w{ --str foo }
        process args
        should eql 'foo'
        args.should have(0).items
      end

      it "expects an argument" do
        args = %w{ --str }
        expect { process args }.to raise_error(RuntimeError, "value expected for option: --str")
      end
    end

    describe "optional" do
      def option_data
        {
          :tags => %w{ --sopt },
          :arg  => [ :string, :optional ],
          :set  => Proc.new { |v| @value = v }
        }
      end
      
      it "takes an argument" do
        process %w{ --sopt xyz }
        should eq 'xyz'
      end

      it "takes an argument with =" do
        process %w{ --sopt=xyz }
        should eq 'xyz'
      end

      it "ignores a missing argument" do
        process %w{ --sopt }
        should be_nil
      end

      it "ignores a following --xyz option" do
        process %w{ --sopt --xyz }
        should be_nil
      end

      it "ignores a following -x option" do
        process %w{ --sopt -x }
        should be_nil
      end
    end
  end
end
