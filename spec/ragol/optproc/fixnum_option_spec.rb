#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/fixnum_option'

Logue::Log.level = Logue::Log::INFO

describe OptProc::FixnumOption do
  before :all do
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end

  subject { @value }

  before do
    @value = nil
    optdata = option_data
    @option = OptProc::Option.new optdata
  end
      
  def process args
    @option.set_value args
  end

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
