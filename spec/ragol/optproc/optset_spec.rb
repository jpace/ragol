#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optset'
require 'ragol/common'
require 'ragol/optproc/common'
require 'ragol/optproc/args'
require 'spec_helper'

describe OptProc::OptionSet do
  include OptProc::OptionTestSets
  
  include_context "common optproc"

  let(:optset) do
    optdata = option_data
    OptProc::OptionSet.new optdata
  end

  describe "#method" do
    describe "OptionSet class (not subclass)" do
      subject { create_abc_option_set.process Array.new }

      valid_methods = [ :alpha, :bravo, :charlie ]
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
            expect { process [ tag, 'foo' ] }.to raise_error(Ragol::OptionException, "abc: invalid option '#{tag}'")
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

  describe "#process" do
    def process args
      optset.process args
    end

    context "when two options are defined" do
      def option_data
        optdata = Array.new
        add_abc_opt optdata
        add_xyz_opt optdata
        optdata
      end

      def process args
        @results = create_abc_option_set.process args
      end

      subject(:results) { @results }

      describe "both options" do
        it "should use the long arg for both options" do
          args = %w{ --abc --xyz }
          optset.process args
          abc.should be_true
          xyz.should be_true
          args.should be_empty
        end  

        it "should use the short arg for both options" do
          args = %w{ -a -x }
          optset.process args
          abc.should be_true
          xyz.should be_true
          args.should be_empty
        end  

        it "should use the short arg for both options and leave unprocessed argument" do
          args = %w{ -a -x foo }
          optset.process args
          abc.should be_true
          xyz.should be_true
          args.should eql %w{ foo }
        end  

        it "should use long arg for first, short for second" do
          args = %w{ --abc -x }
          optset.process args

          abc.should be_true
          xyz.should be_true
          args.should be_empty
        end  

        it "should use short arg for first, long for second" do
          args = %w{ -a --xyz }
          optset.process args

          abc.should be_true
          xyz.should be_true
          args.should be_empty
        end  

        it "should split short args" do
          args = %w{ -ax }
          optset.process args

          abc.should be_true
          xyz.should be_true
          args.should be_empty
        end

        it "should split short args and leave unprocessed argument" do
          args = %w{ -ax foo }
          optset.process args

          abc.should be_true
          xyz.should be_true
          args.should eql %w{ foo }
        end

        it "sets option preceding --" do
          args = %w{ --abc -- foo }
          optset.process args
          abc.should == true
          xyz.should == false
          args.should eql %w{ foo }
        end

        it "ignores option after --" do
          args = %w{ --abc -- --xyz foo }
          optset.process args
          abc.should == true
          xyz.should == false
          args.should eql %w{ --xyz foo }
        end
      end
    end

    context "when number and short options are defined" do
      def option_data
        optdata = Array.new
        @val = nil
        optdata << {
          :regexp => Regexp.new('^-(\d+)'),
          :arg => [ :integer ],
          :set  => Proc.new { |val| @val = val }
        }
        add_xyz_opt optdata
        optdata
      end

      it "should split short args when number is first" do
        args = %w{ -123x }
        optset.process args
        @val.should eql 123
        @xyz.should be_true
        args.should be_empty
      end

      it "should split short args when number is first" do
        args = %w{ -x123 }
        optset.process args
        @val.should eql 123
        @xyz.should be_true
        args.should be_empty
      end
    end

    context "when options are incomplete" do
      def option_data
        optdata = Array.new
        add_abc_opt optdata

        @abcdef = false
        optdata << {
          :tags => %w{ --abcdef },
          :set  => Proc.new { @abcdef = true }
        }

        add_xyz_opt optdata
        optdata
      end

      it "should use the full unambiguous option" do
        args = %w{ --abc }
        process args
        abc.should be_true
        @abcdef.should be_false
        xyz.should be_false
      end

      it "should use the short unambiguous option" do
        args = %w{ --xy }
        process args
        abc.should be_false
        @abcdef.should be_false
        xyz.should be_true
      end

      it "should error on ambiguous options" do
        args = %w{ --ab }
        expect { process(args) }.to raise_error(RuntimeError, "ambiguous match of '--ab'; matches options: (-a, --abc), (--abcdef)")
      end
    end

    context "when regexp" do
      def option_data
        @value = nil
        optdata = Array.new
        optdata << {
          :res => %r{ ^ - ([1-9]\d*) $ }x,
          :set => Proc.new { |val| @value = val },
        }
        optdata
      end

      subject { @value }

      it "should match" do
        args = %w{ -123 }
        process args
        subject.should eql '123'
      end
    end

    context "when one option unsets another" do
      def option_data
        optdata = Array.new
        @ghi = nil
        optdata << {
          :tags => %w{ -g --ghi },
          :set  => Proc.new { @ghi = true },
          :unset => 'xyz',
        }
        add_xyz_opt optdata
        optdata
      end

      [ %w{ --ghi --xyz }, %w{ --xyz --ghi } ].each do |args|
        it "should unset option for #{args}" do
          results = optset.process args
          @ghi.should == true
          results.value('xyz').should be_nil
          # this doesn't work, because there is no 'unset' block to call.
          # @xyz.should == false
          args.should be_empty
        end
      end
    end
  end

  describe "#process" do
    def option_data
      @strval = nil
      optdata = Array.new
      optdata << {
        :tags => %w{ --sopt },
        :arg  => [ :string, :optional ],
        :set  => Proc.new { |v| @strval = v }
      }
      
      add_abc_opt optdata
      optdata
    end
    
    def process args
      optset.process args
    end

    it "takes an argument" do
      process %w{ --sopt xyz }
      @strval.should eq 'xyz'
      abc.should be_false
    end

    it "takes an argument with =" do
      process %w{ --sopt=xyz }
      @strval.should eq 'xyz'
      abc.should be_false
    end

    it "ignores a missing argument" do
      process %w{ --sopt }
      @strval.should be_nil
    end

    it "ignores a following --abc option" do
      args = %w{ --sopt --abc }
      process args
      @strval.should be_true
      abc.should be_true
      args.should be_empty
    end

    it "ignores a following -a option" do
      args = %w{ --sopt -a }
      process args
      @strval.should be_true
      abc.should be_true
      args.should be_empty
    end
  end

  describe "#process" do
    def option_data
      @reval = nil
      optdata = Array.new
      optdata << {
        :tags => %w{ -C --context },
        :res  => %r{ ^ - ([1-9]\d*) $ }x,
        :arg  => [ :optional, :integer ],
        :set  => Proc.new { |val, opt, args| @reval = val || 2 },
      }
      
      add_abc_opt optdata
      optdata
    end
    
    def process args
      optset.process args
    end

    it "takes a tag argument" do
      process %w{ --context 17 }
      @reval.should eq 17
    end

    it "takes a tag argument" do
      process %w{ -C 17 }
      @reval.should eq 17
    end

    it "ignores missing tag argument" do
      process %w{ --context }
      @reval.should eq 2
    end

    it "takes the regexp value (not argument)" do
      process %w{ -17 }
      @reval.should eq 17
    end

    it "takes the regexp value with following -o" do
      args = %w{ -17 -a }
      process args
      @reval.should eq 17
      abc.should be_true
      args.should be_empty
    end
  end
end
