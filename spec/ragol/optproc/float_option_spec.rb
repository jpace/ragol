#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/float_option'
require 'ragol/optproc/common'

Logue::Log.level = Logue::Log::INFO

describe OptProc::FloatOption do
  include_context "common option"

  context "argument" do
    def option_data
      {
        :tags => %w{ --flt },
        :arg  => [ :float ],
        :set  => Proc.new { |val| @value = val }
      }
    end

    it "takes a required argument" do
      process %w{ --flt 3.1415 }
      should eq 3.1415
    end

    it "takes a required integer argument" do
      process %w{ --flt 3 }
      should eq 3
    end

    it "rejects a non-float string" do
      args = %w{ --flt foobar }
      expect { process args }.to raise_error(RuntimeError, "invalid argument 'foobar' for option: --flt")
    end

    it "rejects a non-float string as =" do
      args = %w{ --flt=foobar }
      expect { process args }.to raise_error(RuntimeError, "invalid argument 'foobar' for option: --flt")
    end

    it "rejects a non-float number" do
      args = %w{ --flt 1.3.5 }
      expect { process args }.to raise_error(RuntimeError, "invalid argument '1.3.5' for option: --flt")
    end

    it "rejects a non-float number as =" do
      args = %w{ --flt=1.3.5 }
      expect { process args }.to raise_error(RuntimeError, "invalid argument '1.3.5' for option: --flt")
    end
  end
end
