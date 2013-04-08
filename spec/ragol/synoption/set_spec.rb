#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/set'
require 'ragol/synoption/option'
require 'support/option_sets'

Logue::Log.level = Logue::Log::INFO

describe Synoption::OptionSet do
  include Logue::Loggable, Synoption::OptionTestSets

  shared_examples "defined methods" do |valid_methods, invalid_methods|
    valid_methods.each do |methname|
      it("has method #{methname}") { subject.method(methname).should be_true }
    end

    invalid_methods.each do |methname|
      it("does not have method #{methname}") { expect { subject.method(methname) }.to raise_error(NameError) }
    end
  end

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

    describe "#process" do
      context "when arguments are valid" do
        before :all do
          process %w{ --bravo foo bar baz }
        end

        its(:bravo) { should eql 'foo' }

        [ :alpha, :charlie ].each do |opt|
          its(opt) { should be_nil }
        end

        its(:unprocessed) { should eql %w{ bar baz } }
      end

      context "when arguments are invalid" do
        %w{ -y --bar }.each do |tag|
          it "throws error for invalid tag #{tag}" do
            expect { process [ tag, 'foo' ] }.to raise_error(Synoption::OptionException, "option '#{tag}' invalid for abc")
          end
        end
      end

      context "when arguments contain double dash" do
        before :all do
          process %w{ --alpha bar -- --charlie foo }
        end

        it "sets option preceding --" do
          results.alpha.should eql 'bar'
        end

        it "ignores unspecified option" do
          results.charlie.should be_nil
        end

        it("ignores option following --") do 
          results.bravo.should be_nil
        end

        it "does not include -- in unprocessed" do
          results.unprocessed.should eql %w{ --charlie foo }
        end
      end
    end
  end

  context "when options contain short arguments" do
    describe "#process" do
      def process args
        @results = create_fi_option_set.process args
      end

      subject { @results }
      
      before :all do
        process %w{ -f -i }
      end

      its(:foxtrot) { should be_true }
      its(:india) { should be_true }
    end
  end

  context "when one option unsets another" do
    def process args
      @results = create_abc_option_set(:unsets => :bravo).process args
    end

    subject { @results }
    
    describe "#process" do
      context "when there is no option to unset" do
        before :all do
          process %w{ --bravo foo }
        end

        its(:alpha) { should be_nil }
        its(:bravo) { should eql 'foo' }
        its(:charlie) { should be_nil }
      end

      context "when there is only an option to unset" do
        before :all do
          process %w{ --charlie bar }
        end

        its(:alpha) { should be_nil }
        its(:bravo) { should be_nil }
        its(:charlie) { should eql 'bar' }
      end

      context "when the option order is the unset option, then the option to be unset" do
        before :all do
          process %w{ --charlie baz --bravo foo }
        end

        its(:alpha) { should be_nil }
        its(:bravo) { should be_nil }
        its(:charlie) { should eql 'baz' }
      end

      context "when the option order is the option to be unset, then the unset option" do
        before :all do
          process %w{ --bravo foo --charlie bar }
        end

        its(:alpha) { should be_nil }
        its(:bravo) { should be_nil }
        its(:charlie) { should eql 'bar' }
      end
    end
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
              process %w{ --hotel 8.881bar }
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
end
