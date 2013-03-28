#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/set'
require 'ragol/synoption/option'

Logue::Log.level = Logue::Log::INFO

describe Synoption::OptionSet do
  include Logue::Loggable

  def has_methods(optset, *methnames)
    methnames.each do |field|
      it("has method #{field}") { optset.method(field).should be_true }
    end
  end
  
  def has_no_methods(optset, *methnames)
    methnames.each do |field|
      it("does not have method #{field}") { optset.method(field).should be_nil }
    end
  end
  
  describe "#new" do
    before do
      @xyz = Synoption::Option.new :xyz, '-x', "blah blah xyz",    nil, xyz_options
      @abc = Synoption::Option.new :abc, '-a', "abc yadda yadda",  nil, abc_options
      @tnt = Synoption::Option.new :tnt, '-t', "tnt and so forth", nil, tnt_options
      
      @optset = Synoption::OptionSet.new [ @xyz, @abc, @tnt ]
      def @optset.name; 'testing'; end
    end

    def process args
      @optset.process args
    end

    def abc_options
      Hash.new
    end

    def tnt_options
      Hash.new
    end

    def xyz_options
      Hash.new
    end

    def abc
      @abc.value
    end

    def tnt
      @tnt.value
    end

    def xyz
      @xyz.value
    end

    shared_examples "OptionSet#find_by_name" do
      describe "#find_by_name" do
        valid = [ :abc, :tnt, :xyz ]
        valid.each do |field|
          it "returns true for #{field}" do
            @optset.find_by_name(field).should be_true
          end
        end

        it "returns nil for bfd" do
          @optset.find_by_name(:bfd).should be_nil
        end
      end
    end

    context "when options are isolated" do
      include_examples "OptionSet#find_by_name"

      describe "#process" do
        context "when arguments are valid" do
          before do
            @results = process %w{ -x foo bar baz }
          end
          
          it "sets option xyz" do
            xyz.should eql 'foo'
          end
          
          it "ignores options abc and tnt" do
            abc.should be_nil
            tnt.should be_nil
          end

          it "leaves unprocessed arguments" do
            @results.unprocessed.should eql %w{ bar baz }
          end
        end

        context "when arguments are invalid" do
          it "throws error for bad option" do
            expect { process %w{ -y foo } }.to raise_error(Synoption::OptionException, "option '-y' invalid for testing")
          end
        end

        context "when argument is double dash" do
          before do
            process %w{ -a abc -- -x foo }
          end

          it "sets option preceding --" do
            abc.should eql 'abc'
          end

          it "ignores unspecified option" do
            tnt.should be_nil
          end

          it "ignored option following --" do
            xyz.should be_nil
          end
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
            xyz.should eql 'foo'
          end
          
          it "ignores other options" do
            abc.should be_nil
            tnt.should be_nil
          end
        end

        context "when there is only an option to unset" do
          before do
            process %w{ -t bar }
          end
          
          it "sets the option" do
            tnt.should eql 'bar'
          end
          
          it "unsets the other option" do
            xyz.should be_nil
          end
        end

        context "when the option order is the unset option, then the option to be unset" do
          before do
            process %w{ -t bar -x foo }
          end
          
          it "sets the option" do
            tnt.should eql 'bar'
          end
          
          it "unsets the other option" do
            xyz.should be_nil
          end
        end

        context "when the option order is the option to be unset, then the unset option" do
          before do
            process %w{ -x foo -t bar }
          end
          
          it "sets the option" do
            tnt.should eql 'bar'
          end
          
          it "unsets the other option" do
            xyz.should be_nil
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
        @optset.process args
      end

      context "when options are not interlinked" do
        include_examples "OptionSet#find_by_name"

        context "accessor methods added" do
          valid = [ :abc, :tnt, :xyz ]
          valid.each do |field|
            it "has method #{field}" do
              @optset.method(field).should be_true
            end
          end

          it "does not have method bfd" do
            expect { @optset.method(:bfd) }.to raise_error(NameError)
          end
        end

        describe "#process" do
          context "when arguments are valid" do
            before :all do
              process %w{ -x foo }
            end
            
            it "sets an option" do
              @optset.xyz.should eql 'foo'
            end
            
            it "ignores other options" do
              @optset.abc.should be_nil
              @optset.tnt.should be_nil
            end
          end

          it "resets options on multiple invocations of #process" do
            pending "not supported with current implementation"

            @optset.process %w{ -x foo }
            @optset.xyz.should eql 'foo'
            @optset.abc.should be_nil
            @optset.tnt.should be_nil
            
            @optset.process %w{ -t bar }
            @optset.xyz.should be_nil
            @optset.abc.should be_nil
            @optset.tnt.should eql 'bar'
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
            valid = [ :abc, :ugh, :xyz, :ghi ]
            valid.each do |field|
              it("has method #{field}") { @abcoptset.method(field).should be_true }
            end

            it "does not have method bfd" do
              expect { @abcoptset.method(:bfd) }.to raise_error(NameError)
            end
          end

          context "when option set is common" do
            valid = [ :abc, :ugh ]
            valid.each do |field|
              it "has method #{field}" do
                @commonoptset.method(field).should be_true
              end
            end

            invalid = [ :xyz, :ghi, :bfd ]
            invalid.each do |field|
              it "has does not have method #{field}" do
                expect { @commonoptset.method(field) }.to raise_error(NameError)
              end
            end
          end
        end

        describe "#process" do
          context "when arguments are valid" do
            before :all do
              @results = process %w{ -x foo }
            end
            
            it "sets an option" do
              @abcoptset.xyz.should eql 'foo'
            end
            
            it "ignores other options" do
              @results.abc.should be_nil
              @results.value(:ghi).should be_nil
              @results.value(:ugh).should be_nil
            end
          end

          it "resets options on multiple invocations of #process" do
            pending "not supported with current implementation"

            @abcoptset.process %w{ -x foo }
            @abcoptset.xyz.should eql 'foo'
            @abcoptset.abc.should be_nil
            @abcoptset.tnt.should be_nil
            
            @abcoptset.process %w{ -t bar }
            @abcoptset.xyz.should be_nil
            @abcoptset.abc.should be_nil
            @abcoptset.tnt.should eql 'bar'
          end
        end
      end
    end
  end
end
