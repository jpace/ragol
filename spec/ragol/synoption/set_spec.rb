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
  
  describe "#new" do
    before do
      @optset = create_abc_option_set charlie_options
    end

    def process args
      @results = @optset.process args
    end

    subject { @results }
    
    def charlie_options
      Hash.new
    end

    context "when options are isolated" do
      valid_methods = [ :alpha, :charlie, :bravo ]
      invalid_methods = [ :bfd ]
      
      let(:optset) { @optset }

      describe "#process" do
        context "when arguments are valid" do
          before do
            process %w{ -x foo bar baz }
          end

          it_behaves_like "defined methods", valid_methods, invalid_methods

          its(:bravo) { should eql 'foo' }

          [ :alpha, :charlie ].each do |opt|
            its(opt) { should be_nil }
          end

          its(:unprocessed) { should eql %w{ bar baz } }
        end

        context "when arguments are invalid" do
          it "throws error for bad -o" do
            expect { process %w{ -y foo } }.to raise_error(Synoption::OptionException, "option '-y' invalid for testing")
          end

          it "throws error for bad --option" do
            expect { process %w{ --bar foo } }.to raise_error(Synoption::OptionException, "option '--bar' invalid for testing")
          end
        end

        context "when argument is double dash" do
          before do
            process %w{ -a bar -- -x foo }
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

    context "when options are interlinked" do
      def charlie_options
        { :unsets => :bravo }
      end

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
  end

  context ":has_option" do
    context "when direct subclass of OptionSet" do
      before :all do
        @optset = create_abc_tnt_xyz_option_set_subclass
      end

      def process args
        @results = @optset.process args
      end

      subject { @results }

      context "when options are not interlinked" do
        valid_methods = [ :abc, :tnt, :xyz ]
        invalid_methods = [ :bfd ]

        describe "#process" do
          context "when arguments are valid" do
            before :each do
              process %w{ -x foo }
            end
            
            let(:results) { @results }
            it_behaves_like "defined methods", valid_methods, invalid_methods

            its(:xyz) { should eql 'foo' }
            its(:abc) { should be_nil }
            its(:tnt) { should be_nil }
          end

          describe "multiple invocations" do
            context "first invocation" do
              before :all do
                process %w{ -x foo }
              end
              
              its(:xyz) { should eql 'foo' }
              its(:abc) { should be_nil }
              its(:tnt) { should be_nil }
            end
            
            context "second invocation" do
              before :all do
                process %w{ -t bar }
              end
              
              its(:xyz) { should be_nil }
              its(:abc) { should be_nil }
              its(:tnt) { should eql 'bar' }
            end
          end
        end
      end
    end

    context "when multiple subclasses of OptionSet" do
      before :all do
        @commonoptset = create_common_option_set
        @abcoptset = create_abc_test_option_set
      end

      def process args
        @abcoptset.process args
      end

      context "when options are not interlinked" do
        describe "accessor methods added" do
          context "when option set is subclass" do
            let(:optset) { @abcoptset }

            valid_methods = [ :abc, :ugh, :xyz, :ghi ]
            invalid_methods = [ :bfd ]

            let(:results) { @abcoptset.process [] }

            subject { results }

            it_behaves_like "defined methods", valid_methods, invalid_methods
          end

          context "when option set is common" do
            let(:optset) { @commonoptset }

            subject { results }

            valid_methods = [ :abc, :ugh ]
            invalid_methods = [ :xyz, :ghi, :bfd ]

            let(:results) { @commonoptset.process [] }
            
            it_behaves_like "defined methods", valid_methods, invalid_methods
          end
        end

        describe "#process" do
          context "when arguments are valid" do
            before :all do
              @results = process %w{ -x foo }
            end

            let(:results) { @results }

            subject { @results }

            its(:xyz) { should eql 'foo' }
            its(:abc) { should be_nil }
            its(:ghi) { should be_nil }
            its(:ugh) { should be_nil }
          end

          describe "multiple invocations" do
            context "first invocation" do
              before :all do
                @results = process %w{ -x foo }
              end

              subject { @results }
              
              its(:abc) { should be_nil }
              its(:ghi) { should be_nil }
              its(:ugh) { should be_nil }
              its(:xyz) { should eql 'foo' }
            end

            context "second invocation" do
              before :all do
                @results = process %w{ -g bar }
              end

              subject { @results }
              
              its(:abc) { should be_nil }
              its(:ghi) { should eql 'bar' }
              its(:ugh) { should be_nil }
              its(:xyz) { should be_nil }
            end
          end
        end
      end
    end
  end
end
