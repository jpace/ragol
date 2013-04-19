#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optset'

shared_context "common optproc" do
  def add_abc_opt optdata
    @abc = false
    optdata << {
      :tags => %w{ -a --abc },
      :set  => Proc.new { @abc = true }
    }
  end

  def add_xyz_opt optdata
    @xyz = false
    optdata << {
      :tags => %w{ -x --xyz },
      :set  => Proc.new { @xyz = true }
    }
  end

  def abc
    @abc
  end

  def xyz
    @xyz
  end

  subject { @value }

  let(:option) { OptProc::Option.new option_data }
  
  def process args
    optset = OptProc::OptionSet.new [ option_data ]
    optset.process args
  end
  
  def process_option args
    optset = OptProc::OptionSet.new [ option_data ]
    @results = optset.process args
  end
end
