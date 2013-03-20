#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optproc'
require 'ragol/optproc/factory'
require 'ragol/optproc/option'

Logue::Log.level = Logue::Log::INFO

describe OptProc::OptionFactory do
  describe "regexp option" do
    before do
      value = nil
      optdata = {
        :regexp => %r{ ^ - (1\d*) $ }x,
      }
      @option = OptProc::OptionFactory.instance.create optdata
    end

    subject { @option }

    it { should be_a_kind_of(OptProc::RegexpOption) }
  end

  describe "tag option" do
    before do
      value = nil
      optdata = {
        :tags => %w{ --xyz }
      }
      @option = OptProc::OptionFactory.instance.create optdata
    end

    subject { @option }

    it { should be_a_kind_of(OptProc::TagOption) }
  end
end
