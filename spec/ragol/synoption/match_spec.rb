#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/match'
require 'spec_helper'

describe "Synoption::OptionMatch" do
  def match? tag
    matcher.match? tag
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
