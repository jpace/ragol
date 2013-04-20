#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/common/matcher'
require 'spec_helper'

describe Ragol::Matcher do
  describe "#score" do
    before :all do
      @matcher = Ragol::Matcher.new [ '-x', '--foo', Regexp.new('^--no-?bar') ]
    end

    subject { @matcher }
    
    context "when short tag" do
      it "should fully match" do
        @matcher.score('-x').should eql 1.0
      end
      
      it "should not match" do
        @matcher.score('-y').should be_nil
      end
      
      it "should not match" do
        @matcher.score('-f').should be_nil
      end
    end
    
    context "when string long tag" do
      it "should fully match" do
        @matcher.score('--foo').should eql 1.0
      end
      
      it "should partial match" do
        score = @matcher.score('--fo')
        score.should < 1.0
        score.should > 0.0
      end
      
      it "should not match" do
        @matcher.score('--qux').should be_nil
      end
    end
    
    context "when regexps long tag" do
      it "should fully match" do
        @matcher.score('--no-bar').should eql 1.0
      end
      
      it "should fully match" do
        @matcher.score('--nobar').should eql 1.0
      end
    end
  end
end
