#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/boolean_option'

Logue::Log.level = Logue::Log::INFO

describe OptProc::BooleanOption do
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
    def option_data
      {
        :tags => %w{ --bool },
        :arg  => [ :boolean ],
        :set  => Proc.new { |val| @value = val }
      }      
    end

    %w{ true yes on }.each do |val|
      it "takes #{val} as true" do
        process [ '--bool', val ]
        should eq true
      end
    end
    
    %w{ false no off }.each do |val|
      it "takes #{val} as false" do
        process [ '--bool', val ]
        should eq false
      end
    end

    it "rejects a non-boolean" do
      args = %w{ --bool oui }
      expect { process args }.to raise_error(RuntimeError, "invalid argument 'oui' for option: --bool")
    end

    it "rejects a non-boolean as =" do
      args = %w{ --bool=oui }
      expect { process args }.to raise_error(RuntimeError, "invalid argument 'oui' for option: --bool")
    end
  end
end
