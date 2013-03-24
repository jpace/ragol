#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/option'

Logue::Log.level = Logue::Log::INFO

describe Synoption::Option do
  describe "option defaults" do
    let(:option) do
      Synoption::Option.new :limit, '-l', "the number of log entries", nil
    end

    subject { option }

    it { option.name.should eql :limit }
    it { option.tag.should eql '-l' }
    it { option.description.should eql 'the number of log entries' }
  end

  describe "initial value" do
    let(:option) do
      Synoption::Option.new :nombre, '-x', " one two three", 133
    end

    subject { option }

    it { option.value.should eql 133 }
  end

  describe "documentation" do
    let(:option) do
      Synoption::Option.new :limit, '-l', "the number of log entries", 777, :negate => [ %r{^--no-?limit} ]
    end

    subject { option }

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

  describe "exact match" do
    let(:option) do
      Synoption::Option.new :limit, '-l', "the number of log entries", 3
    end

    subject { option }

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

  describe "negative match" do
    let(:option) do
      Synoption::Option.new :limit, '-l', "the number of log entries", 777, :negate => [ '-L', %r{^--no-?limit} ]
    end

    subject { option }

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

  describe "regexp match" do
    let(:option) do
      Synoption::Option.new :revision, '-r', "the revision", nil, :regexp => Regexp.new('^[\-\+]\d+$')
    end

    subject { option }

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
    let(:option) do
      Synoption::Option.new :xyz, '-x', "the blah blah blah", nil, Hash.new
    end

    subject { option }

    def process args
      option.process args
    end

    it "should not process non-matching tag" do
      args = %w{ --baz foo }
      pr = process args
      pr.should be_false
      option.value.should be_nil
      args.size.should == 2
    end

    it "takes argument" do
      args = %w{ --xyz foo }
      pr = process args
      pr.should be_true
      option.value.should eql 'foo'
      args.should be_empty
    end

    it "takes argument and leaves one" do
      args = %w{ --xyz foo bar }
      pr = process args
      pr.should be_true
      option.value.should eql 'foo'
      args.should eql [ 'bar' ]
    end

    it "raises error without required argument" do
      args = %w{ --xyz }
      expect { process(args) }.to raise_error(RuntimeError)
    end
  end

  describe "process negative" do
    let(:option) do
      opts = { :negate => [ '-X', %r{^--no-?xyz} ] }
      Synoption::Option.new :xyz, '-x', "the blah blah blah", nil, opts
    end

    subject { option }

    def process args
      option.process args
    end

    %w{ -X --no-xyz --noxyz }.each do |val|
      it "matches #{val} with no following argument" do
        args = [ val ]
        pr = process args
        pr.should be_true
        option.value.should be_false
        args.should be_empty
      end

      it "matches #{val} with following argument" do
        args = [ val, '--abc' ]
        pr = process args
        pr.should be_true
        option.value.should be_false
        args.should eql [ '--abc' ]
      end
    end
  end

  describe "process regexp" do
    let(:option) do
      opts = { :regexp => Regexp.new('^[\-\+]\d+$') }
      Synoption::Option.new :xyz, '-x', "the blah blah blah", nil, opts
    end

    subject { option }

    def process args
      option.process args
    end

    %w{ -1 +123 }.each do |val|
      it "matches #{val} with no following argument" do
        args = [ val ]
        pr = process args
        pr.should be_true
        option.value.should be_true
        args.should be_empty
      end
    end

    %w{ -1 +123 }.each do |val|
      it "matches #{val} with following argument" do
        args = [ val, '--foo' ]
        pr = process args
        pr.should be_true
        option.value.should be_true
        args.should eql [ '--foo' ]
      end
    end
  end
end
