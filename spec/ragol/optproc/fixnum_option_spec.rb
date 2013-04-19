#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/fixnum_option'
require 'ragol/optproc/common'
require 'spec_helper'

Logue::Log.level = Logue::Log::INFO

describe OptProc::FixnumOption do
  include_context "common optproc"

  context "argument" do
    describe "required (implicit)" do
      def option_data
        {
          :tags => %w{ -d --delta },
          :arg  => [ :integer ],
          :set  => Proc.new { |v| @value = v }
        }
      end
      
      it_behaves_like "a fixnum option" do
        let(:value) { @value }
      end
    end
  end
end
