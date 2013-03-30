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
      @optset = create_abc_tnt_xyz tnt_options
    end

    def process args
      @results = @optset.process args
    end

    def tnt_options
      Hash.new
    end

    context "when options are isolated" do
      valid_methods = [ :abc, :tnt, :xyz ]
      invalid_methods = [ :bfd ]
      
      let(:optset) { @optset }

      describe "#process" do
        context "when arguments are valid" do
          before do
            @results = process %w{ -x foo bar baz }
          end

          let(:results) { @results }
          it_behaves_like "defined methods", valid_methods, invalid_methods

          subject { @results }

          its(:xyz) { should eql 'foo' }

          [ :abc, :tnt ].each do |opt|
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
            process %w{ -a abc -- -x foo }
          end

          it "sets option preceding --" do
            @results.abc.should eql 'abc'
          end

          it "ignores unspecified option" do
            @results.tnt.should be_nil
          end

          it("ignores option following --") { @results.xyz.should be_nil }
        end
      end
    end

    context "when options are interlinked" do
      def tnt_options
        { :unsets => :xyz }
      end

      describe "#process" do
        context "when there is no option to unset" do
          before do
            process %w{ -x foo }
          end
          
          it "sets the option" do
            @results.xyz.should eql 'foo'
          end
          
          it "ignores other options" do
            @results.abc.should be_nil
            @results.tnt.should be_nil
          end
        end

        context "when there is only an option to unset" do
          before do
            process %w{ -t bar }
          end
          
          it "sets the option" do
            @results.tnt.should eql 'bar'
          end
          
          it "unsets the other option" do
            @results.xyz.should be_nil
          end
        end

        context "when the option order is the unset option, then the option to be unset" do
          before do
            process %w{ -t bar -x foo }
          end
          
          it "sets the option" do
            @results.tnt.should eql 'bar'
          end
          
          it "unsets the other option" do
            @results.xyz.should be_nil
          end
        end

        context "when the option order is the option to be unset, then the unset option" do
          before do
            process %w{ -x foo -t bar }
          end
          
          it "sets the option" do
            @results.tnt.should eql 'bar'
          end
          
          it "unsets the other option" do
            @results.xyz.should be_nil
          end
        end
      end
    end
  end

  context ":has_option" do
    context "when direct subclass of OptionSet" do
      before :all do
        class XyzOption < Synoption::Option
          def initialize
            super :xyz, '-x', "blah blah xyz", nil
          end
        end

        class AbcOption < Synoption::Option
          def initialize 
            super :abc, '-a', "abc yadda yadda",  nil
          end
        end
        
        class TntOption < Synoption::Option
          def initialize 
            super :tnt, '-t', "tnt and so forth", nil
          end
        end
        
        class TestOptionSet < Synoption::OptionSet
          has_option :xyz, XyzOption
          has_option :abc, AbcOption
          has_option :tnt, TntOption

          def name; 'testing'; end
        end

        @optset = TestOptionSet.new
      end

      def process args
        @results = @optset.process args
      end

      context "when options are not interlinked" do
        valid_methods = [ :abc, :tnt, :xyz ]
        invalid_methods = [ :bfd ]

        describe "#process" do
          context "when arguments are valid" do
            before :each do
              @results = process %w{ -x foo }
            end

            let(:results) { @results }
            it_behaves_like "defined methods", valid_methods, invalid_methods

            subject { results }
            
            it "sets an option" do
              @results.xyz.should eql 'foo'
            end
            
            it "ignores other options" do
              @results.abc.should be_nil
              @results.tnt.should be_nil
            end
          end

          it "resets options on multiple invocations of #process" do
            process %w{ -x foo }
            @results.xyz.should eql 'foo'
            @results.abc.should be_nil
            @results.tnt.should be_nil
            
            process %w{ -t bar }
            @results.xyz.should be_nil
            @results.abc.should be_nil
            @results.tnt.should eql 'bar'
          end
        end
      end
    end

    context "when multiple subclasses of OptionSet" do
      before :all do
        class AbcOption < Synoption::Option
          def initialize
            super :abc, '-a', "aye bee see", nil
          end
        end

        class UghOption < Synoption::Option
          def initialize
            super :ugh, '-u', "you gee ache", nil
          end
        end
        
        class CommonTestOptionSet < Synoption::OptionSet
          has_option :abc, AbcOption
          has_option :ugh, UghOption

          def name; 'common'; end
        end

        @commonoptset = CommonTestOptionSet.new

        class XyzOption < Synoption::Option
          def initialize
            super :xyz, '-x', "ecks why zee", nil
          end
        end

        class GhiOption < Synoption::Option
          def initialize
            super :ghi, '-g', "gee ache eye", nil
          end
        end
        
        class AbcTestOptionSet < CommonTestOptionSet
          has_option :xyz, XyzOption
          has_option :ghi, GhiOption

          def name; 'testing'; end
        end

        @abcoptset = AbcTestOptionSet.new
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
            
            it "sets an option" do
              @results.xyz.should eql 'foo'
            end
            
            it "ignores other options" do
              @results.abc.should be_nil
              @results.ghi.should be_nil
              @results.ugh.should be_nil
            end
          end

          it "resets options on multiple invocations of #process" do
            @results = process %w{ -x foo }
            @results.abc.should be_nil
            @results.ghi.should be_nil
            @results.ugh.should be_nil
            @results.xyz.should eql 'foo'
            
            @results = process %w{ -g bar }
            @results.abc.should be_nil
            @results.ghi.should eql 'bar'
            @results.ugh.should be_nil
            @results.xyz.should be_nil
          end
        end
      end
    end
  end
end
