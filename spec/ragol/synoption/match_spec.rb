#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/match'

Logue::Log.level = Logue::Log::INFO

describe Synoption::OptionMatch do
  def match? tag
    matcher.match? tag
  end
  
  describe "exact match" do
    let(:matcher) do
      Synoption::OptionExactMatch.new '-t', 'tagname'
    end

    it { match?('-t').should be_true }
    it { match?('--tagname').should be_true }

    it { match?('-T').should be_false }
    it { match?('--tag-name').should be_false }
    it { match?('--no-tagname').should be_false }
    it { match?('--notagname').should be_false }
  end

  describe "negative tag match" do
    let(:matcher) do
      Synoption::OptionNegativeMatch.new '-T'
    end

    it { match?('-T').should be_true }
    it { match?('-t').should be_false }
  end

  describe "negative regexp match" do
    let(:matcher) do
      Synoption::OptionNegativeMatch.new %r{^\-\-no\-?tagname$}
    end

    it { match?('--no-tagname').should be_true }
    it { match?('--notagname').should be_true }

    it { match?('-t').should be_false }
    it { match?('--non-tagname').should be_false }
    it { match?('--nontagname').should be_false }
  end

  describe "negative multiple tags match" do
    let(:matcher) do
      Synoption::OptionNegativeMatch.new %r{^\-\-no\-?tagname$}, '-T'
    end

    it { match?('--no-tagname').should be_true }
    it { match?('--notagname').should be_true }
    it { match?('-T').should be_true }

    it { match?('--tagname').should be_false }
    it { match?('-t').should be_false }
  end

  describe "regexp match" do
    let(:matcher) do
      Synoption::OptionRegexpMatch.new %r{^--tag-?name$}
    end

    it { match?('--tagname').should be_true }
    it { match?('--tag-name').should be_true }

    it { match?('--tagnames').should be_false }
    it { match?('--tag--name').should be_false }
  end
end
