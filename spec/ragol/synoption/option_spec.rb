#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/option'
require 'ragol/synoption/set'
require 'ragol/synoption/results'
require 'support/option_sets'

# Logue::Log.level = Logue::Log::INFO

describe Synoption::Option do
  include Synoption::OptionTestSets
  
  describe "defaults" do
    subject(:option) do
      Synoption::Option.new :limit, '-l', "the number of log entries", 777
    end

    its(:name) { should eql :limit }
    its(:tag) { should eql '-l' }
    its(:value) { should eql 777 }
    its(:description) { should eql 'the number of log entries' }
  end

  describe "#to_doc" do
    context "without negatives" do
      subject(:option) do
        Synoption::Option.new :limit, '-l', "the number of log entries", 777
      end

      it "should show documentation" do
        sio = StringIO.new
        option.to_doc sio
        exp = String.new
        exp << "  -l [--limit] ARG         : the number of log entries\n"
        exp << "                               default: 777\n"
        sio.string.should eql exp
      end
    end

    context "with negatives" do
      subject(:option) do
        Synoption::Option.new :limit, '-l', "the number of log entries", 777, :negate => [ %r{^--no-?limit} ]
      end

      it "should show documentation" do
        sio = StringIO.new
        option.to_doc sio
        exp = String.new
        exp << "  -l [--limit] ARG         : the number of log entries\n"
        exp << "                               default: 777\n"
        exp << "  --no-limit                 \n"
        sio.string.should eql exp
      end
    end
  end
  
  describe "#exact_match" do
    subject(:option) do
      Synoption::Option.new :limit, '-l', "the number of log entries", 3
    end

    [ '-l', '--limit' ].each do |val|
      it "should exactly match #{val}" do
        option.exact_match?(val).should be_true
      end
    end

    [ '-L', '-x', '--lim', '--liMit' ].each do |val|
      it "should not exactly match #{val}" do
        option.exact_match?(val).should be_false
      end
    end
  end

  describe "#negative_match" do
    subject(:option) do
      Synoption::Option.new :limit, '-l', "the number of log entries", 777, :negate => [ '-L', %r{^--no-?limit} ]
    end

    [ '-L', '--no-limit', '--nolimit' ].each do |val|
      it "should negatively match #{val}" do
        option.negative_match?(val).should be_true
      end
    end

    [ '-l', '-x', '-nolimit', '  --nolimit' ].each do |val|
      it "should not negatively match #{val}" do
        option.negative_match?(val).should be_false
      end
    end
  end

  describe "#regexp_match" do
    subject(:option) do
      Synoption::Option.new :revision, '-r', "the revision", nil, :regexp => Regexp.new('^[\-\+]\d+$')
    end

    [ '-1', '-123', '+99', '+443' ].each do |val|
      it "should regexp match #{val}" do
        option.regexp_match?(val).should be_true
      end
    end

    [ '-x', '123', '+-x', 'word' ].each do |val|
      it "should not regexp match #{val}" do
        option.regexp_match?(val).should be_false
      end
    end
  end

  describe "process positive" do
    subject(:option) do
      Synoption::Option.new :xyz, '-x', "the blah blah blah", nil, Hash.new
    end

    def process args
      optset = Synoption::OptionSet.new
      optset.add option
      def optset.name; 'testing'; end
      @results = optset.process args
    end

    context "when it has matching tag and no following arguments" do
      before :all do
        process %w{ --xyz foo }
      end
      
      it "should change the option value" do
        @results.xyz.should eql 'foo'
      end

      it "should take the arguments" do
        @results.unprocessed.should be_empty
      end
    end

    context "when it has matching tag and a following argument" do
      before :all do
        process %w{ --xyz foo bar }
      end

      it "should change the option value" do
        @results.xyz.should eql 'foo'
      end

      it "should leave the remaining argument" do
        @results.unprocessed.should eql [ 'bar' ]
      end
    end

    it "raises error without required argument" do
      args = %w{ --xyz }
      expect { process(args) }.to raise_error(RuntimeError, "option xyz expects following argument")
    end
  end

  describe "process negative" do
    subject(:option) do
      opts = { :negate => [ '-X', %r{^--no-?xyz} ] }
      Synoption::Option.new :xyz, '-x', "the blah blah blah", nil, opts
    end

    def process args
      @results = Synoption::Results.new [ option ]
      option.process @results, args
    end

    %w{ -X --no-xyz --noxyz }.each do |val|
      it "matches #{val} with no following argument" do
        args = [ val ]
        process args
        @results.xyz.should == false
        args.should be_empty
      end

      it "matches #{val} with following argument" do
        args = [ val, '--abc' ]
        process args
        @results.xyz.should == false
        args.should eql [ '--abc' ]
      end
    end
  end

  describe "process regexp" do
    subject(:option) do
      opts = { :regexp => Regexp.new('^[\-\+]\d+$') }
      Synoption::Option.new :xyz, '-x', "the blah blah blah", nil, opts
    end

    def process args
      @results = Synoption::Results.new [ option ]
      option.process @results, args
    end

    %w{ -1 +123 }.each do |val|
      it "matches #{val} with no following argument" do
        args = [ val ]
        process args
        @results.xyz.should be_true
        args.should be_empty
      end
    end

    %w{ -1 +123 }.each do |val|
      it "matches #{val} with following argument" do
        args = [ val, '--foo' ]
        process args
        @results.xyz.should be_true
        args.should eql [ '--foo' ]
      end
    end
  end
  
  describe "name match" do
    subject(:option) do
      Synoption::Option.new :max_limit, '-m', "the maximum", nil
    end

    it "should convert underscores and dashes" do
      option.exact_match?('--max-limit').should be_true
    end
  end
end
