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
      @optset = create_abc_tnt_xyz_option_set tnt_options
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

          subject { @results }

          it "sets option preceding --" do
            subject.abc.should eql 'abc'
          end

          it "ignores unspecified option" do
            subject.tnt.should be_nil
          end

          it("ignores option following --") { subject.xyz.should be_nil }
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

          subject { @results }

          it "sets the option" do
            subject.xyz.should eql 'foo'
          end
          
          it "ignores other options" do
            subject.abc.should be_nil
            subject.tnt.should be_nil
          end
        end

        context "when there is only an option to unset" do
          before do
            process %w{ -t bar }
          end

          subject { @results }
          
          it "sets the option" do
            subject.tnt.should eql 'bar'
          end
          
          it "unsets the other option" do
            subject.xyz.should be_nil
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
            
            it "sets an option" do
              subject.xyz.should eql 'foo'
            end
            
            it "ignores other options" do
              subject.abc.should be_nil
              subject.ghi.should be_nil
              subject.ugh.should be_nil
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
