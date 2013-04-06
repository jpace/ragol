#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/common/tags'

Logue::Log.level = Logue::Log::INFO

describe Ragol::Tags do
  describe "#score" do
    before :all do
      @tags = Ragol::Tags.new [ '-x', '--foo', Regexp.new('^--no-?bar') ]
    end

    subject { @tags }
    
    context "when short tag" do
      it "should fully match" do
        @tags.score('-x').should eql 1.0
      end
      
      it "should not match" do
        @tags.score('-y').should be_nil
      end
    end
    
    context "when string long tag" do
      it "should fully match" do
        @tags.score('--foo').should eql 1.0
      end
      
      it "should partial match" do
        score = @tags.score('--fo')
        score.should < 1.0
        score.should > 0.0
      end
      
      it "should not match" do
        @tags.score('--qux').should be_nil
      end
    end
    
    context "when regexps long tag" do
      it "should fully match" do
        @tags.score('--no-bar').should eql 1.0
      end
      
      it "should fully match" do
        @tags.score('--nobar').should eql 1.0
      end
    end
  end
end
