#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/string_option'
require 'ragol/optproc/common'
require 'spec_helper'

describe OptProc::StringOption do
  include_context "common optproc"

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

      it "takes an argument with =" do
        process [ '--str="xyz"' ]
        should eq 'xyz'
      end

      it "takes an argument with =" do
        process [ "--str='xyz'" ]
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
  end
end
