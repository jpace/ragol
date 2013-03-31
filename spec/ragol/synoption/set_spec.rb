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
  
  context "when options are isolated" do
    before do
      @optset = create_abc_option_set
    end

    def process args
      @results = @optset.process args
    end

    subject { @results }

    describe "#process" do
      valid_methods = [ :alpha, :charlie, :bravo ]
      invalid_methods = [ :bfd ]
      
      let(:optset) { @optset }

      context "when arguments are valid" do
        before do
          process %w{ --bravo foo bar baz }
        end

        it_behaves_like "defined methods", valid_methods, invalid_methods

        its(:bravo) { should eql 'foo' }

        [ :alpha, :charlie ].each do |opt|
          its(opt) { should be_nil }
        end

        its(:unprocessed) { should eql %w{ bar baz } }
      end

      context "when arguments are invalid" do
        %w{ -y --bar }.each do |tag|
          it "throws error for invalid tag #{tag}" do
            expect { process [ tag, 'foo' ] }.to raise_error(Synoption::OptionException, "option '#{tag}' invalid for testing")
          end
        end
      end

      context "when arguments contain double dash" do
        before do
          process %w{ --alpha bar -- --charlie foo }
        end

        it "sets option preceding --" do
          subject.alpha.should eql 'bar'
        end

        it "ignores unspecified option" do
          subject.charlie.should be_nil
        end

        it("ignores option following --") { subject.bravo.should be_nil }
      end
    end
  end

  context "when one option unsets another" do
    before do
      @optset = create_abc_option_set(:unsets => :bravo)
    end

    def process args
      @results = @optset.process args
    end

    subject { @results }
    
    describe "#process" do
      context "when there is no option to unset" do
        before do
          process %w{ --bravo foo }
        end

        its(:bravo) { should eql 'foo' }
        its(:alpha) { should be_nil }
        its(:charlie) { should be_nil }
      end

      context "when there is only an option to unset" do
        before do
          process %w{ --charlie bar }
        end

        its(:charlie) { should eql 'bar' }
        its(:bravo) { should be_nil }
      end

      context "when the option order is the unset option, then the option to be unset" do
        before do
          process %w{ --charlie bar --bravo foo }
        end

        its(:charlie) { should eql 'bar' }
        its(:bravo) { should be_nil }
      end

      context "when the option order is the option to be unset, then the unset option" do
        before do
          process %w{ --bravo foo --charlie bar }
        end

        its(:charlie) { should eql 'bar' }
        its(:bravo) { should be_nil }
      end
    end
  end

  context ":has_option" do
    context "when direct subclass of OptionSet" do
      before :all do
        @optset = create_def_option_set
      end

      def process args
        @results = @optset.process args
      end

      subject { @results }

      context "when options are not interlinked" do
        valid_methods = [ :delta, :foxtrot, :echo ]
        invalid_methods = [ :bfd ]

        describe "#process" do
          context "when arguments are valid" do
            before :each do
              process %w{ --echo foo }
            end
            
            let(:results) { @results }
            it_behaves_like "defined methods", valid_methods, invalid_methods

            its(:echo) { should eql 'foo' }
            its(:delta) { should be_nil }
            its(:foxtrot) { should be_nil }
          end

          describe "multiple invocations" do
            context "first invocation" do
              before :all do
                process %w{ --echo foo }
              end
              
              its(:echo) { should eql 'foo' }
              its(:delta) { should be_nil }
              its(:foxtrot) { should be_nil }
            end
            
            context "second invocation" do
              before :all do
                process %w{ --foxtrot bar }
              end
              
              its(:echo) { should be_nil }
              its(:delta) { should be_nil }
              its(:foxtrot) { should eql 'bar' }
            end
          end
        end
      end
    end

    context "when multiple subclasses of OptionSet" do
      before :all do
        @dgehoptset = create_dgeh_option_set
      end

      def process args
        @dgehoptset.process args
      end

      describe "#method" do
        context "when option set is subclass" do
          let(:optset) { @dgehoptset }

          valid_methods = [ :delta, :golf, :echo, :hotel ]
          invalid_methods = [ :bfd ]

          let(:results) { @dgehoptset.process [] }

          subject { results }

          it_behaves_like "defined methods", valid_methods, invalid_methods
        end

        context "when option set is common" do
          valid_methods = [ :delta, :golf ]
          invalid_methods = [ :echo, :hotel, :bfd ]

          subject { create_dg_option_set.process [] }
          
          it_behaves_like "defined methods", valid_methods, invalid_methods
        end
      end

      describe "#process" do
        context "when arguments are valid" do
          before :all do
            @results = process %w{ --echo foo }
          end

          let(:results) { @results }

          subject { @results }

          its(:echo) { should eql 'foo' }
          its(:delta) { should be_nil }
          its(:hotel) { should be_nil }
          its(:golf) { should be_nil }
        end

        describe "multiple invocations" do
          context "first invocation" do
            before :all do
              @results = process %w{ --echo foo }
            end

            subject { @results }
            
            its(:delta) { should be_nil }
            its(:hotel) { should be_nil }
            its(:golf) { should be_nil }
            its(:echo) { should eql 'foo' }
          end

          context "second invocation" do
            before :all do
              @results = process %w{ --hotel bar }
            end

            subject { @results }
            
            its(:delta) { should be_nil }
            its(:hotel) { should eql 'bar' }
            its(:golf) { should be_nil }
            its(:echo) { should be_nil }
          end
        end
      end
    end
  end
end
