#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/set'
require 'ragol/synoption/option'
require 'support/option_sets'
require 'spec_helper'

describe Synoption::OptionSet do
  include Logue::Loggable, Synoption::OptionTestSets

  describe "#method" do
    describe "OptionSet class (not subclass)" do
      subject { create_abc_option_set.process Array.new }

      valid_methods = [ :alpha, :bravo, :charlie ]
      invalid_methods = [ :bfd ]
      
      it_behaves_like "defined methods", valid_methods, invalid_methods
    end

    describe "OptionSet subclass" do
      subject { create_def_option_set.process Array.new }

      valid_methods = [ :delta, :echo, :foxtrot ]
      invalid_methods = [ :bfd ]
      
      it_behaves_like "defined methods", valid_methods, invalid_methods
    end
  end
  
  context "when options are isolated" do
    def process args
      @results = create_abc_option_set.process args
    end

    subject(:results) { @results }

    it_behaves_like "an option set"
  end

  context "when options contain short arguments" do
    def process args
      @results = create_fij_option_set.process args
    end

    subject { @results }

    it_behaves_like "an option set with short arguments"
  end

  context "when one option unsets another" do
    def process args
      @results = create_abc_option_set(:unsets => :bravo).process args
    end

    subject { @results }

    it_behaves_like "an option set with unset options"
  end

  context ":has_option" do
    context "when direct subclass of OptionSet" do
      def process args
        @results = create_def_option_set.process args
      end

      subject { @results }

      context "when options are not interlinked" do
        describe "#process" do
          context "when arguments are valid" do
            before :all do
              process %w{ --echo foo }
            end

            its(:delta) { should eql 317 }
            its(:echo) { should eql 'foo' }
            its(:foxtrot) { should be_false }
          end

          describe "multiple invocations" do
            context "first invocation" do
              before :all do
                process %w{ --echo foo }
              end
              
              its(:delta) { should eql 317 }
              its(:echo) { should eql 'foo' }
              its(:foxtrot) { should be_false }
            end
            
            context "second invocation" do
              before :all do
                process %w{ --foxtrot bar }
              end
              
              its(:delta) { should eql 317 }
              its(:echo) { should eql 'default default' }
              its(:foxtrot) { should be_true }
            end
          end
        end
      end
    end

    context "when multiple subclasses of OptionSet" do
      def process args
        @results = create_defgh_option_set.process args
      end

      subject { @results }

      describe "#process" do
        context "when arguments are valid" do
          before :all do
            process %w{ --echo foo }
          end
          
          its(:delta) { should eql 317 }
          its(:echo) { should eql 'foo' }
          its(:foxtrot) { should be_false }
          its(:golf) { should be_nil }
          its(:hotel) { should eql 8.79 }
        end

        describe "multiple invocations" do
          context "first invocation" do
            before :all do
              process %w{ --echo foo }
            end
            
            its(:delta) { should eql 317 }
            its(:echo) { should eql 'foo' }
            its(:foxtrot) { should be_false }
            its(:golf) { should be_nil }
            its(:hotel) { should eql 8.79 }
          end

          context "second invocation" do
            before :all do
              process %w{ --hotel 8.881 bar }
            end
            
            its(:delta) { should eql 317 }
            its(:echo) { should eql 'default default' }
            its(:foxtrot) { should be_false }
            its(:golf) { should be_nil }
            its(:hotel) { should eql 8.881 }
          end
        end
      end
    end
  end

  context "when options partially match" do
    class DelayOption < Synoption::Option
      def initialize
        super :delay, '-y', "waiting period", nil
      end
    end

    class DdOptionSet < Synoption::OptionSet
      has_option :delta, Synoption::OptionTestSets::DeltaOption
      has_option :delay, DelayOption
    end

    def process args
      @results = DdOptionSet.new.process args
    end

    subject { @results }

    describe "#process" do
      context "when arguments are full" do
        before :all do
          process %w{ --delay 44 --delta 6 }
        end
        
        its(:delay) { should eql '44' }
        its(:delta) { should eql 6 }
      end

      context "when arguments are partial" do
        before :all do
          process %w{ --dela 144 --delt 37 }
        end
        
        its(:delay) { should eql '144' }
        its(:delta) { should eql 37 }
      end

      context "when arguments are conflicting partial" do
        it "should error on ambiguous options" do
          args = %w{ --del 144 --del 37 }
          expect { process(args) }.to raise_error(RuntimeError, "ambiguous match of '--del'; matches options: (-d, --delta), (-y, --delay)")
        end
      end
    end
  end

  context "when argument is optional" do
    def process args
      @results = create_ik_option_set.process args
    end

    subject { @results }

    %w{ -k --kilo }.each do |val|
      it "matches #{val} with no following argument" do
        process [ val ]
        @results.kilo.should == nil
        @results.india.should be_false
        @results.unprocessed.should be_empty
      end

      it "matches #{val} with following argument" do
        process [ val, 'abc' ]
        @results.kilo.should eql 'abc'
        @results.india.should be_false
        @results.unprocessed.should be_empty
      end

      it "matches #{val} with following option" do
        process [ val, '-i' ]
        @results.kilo.should eql true
        @results.india.should be_true
        @results.unprocessed.should be_empty
      end
    end
  end
end
