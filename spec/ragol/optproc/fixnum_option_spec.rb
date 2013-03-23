#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/fixnum_option'
require 'ragol/optproc/common'

Logue::Log.level = Logue::Log::INFO

describe OptProc::FixnumOption do
  include_context "common option"

  context "argument" do
    describe "required (implicit)" do
      def option_data
        {
          :tags => %w{ --int },
          :arg  => [ :integer ],
          :set  => Proc.new { |v| @value = v }
        }
      end

      it "takes an argument" do
        process %w{ --int 1 }
        should eq 1
      end

      it "rejects a non-integer" do
        args = %w{ --int 1.0 }
        expect { process args }.to raise_error(RuntimeError, "invalid argument '1.0' for option: --int")
        should be_nil
      end

      it "rejects a non-integer as =" do
        args = %w{ --int=1.0 }
        expect { process args }.to raise_error(RuntimeError, "invalid argument '1.0' for option: --int")
        should be_nil
      end
    end
  end
end
