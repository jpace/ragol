#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optset'

describe OptProc::OptionSet do
  before :all do
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end

  describe "#new" do
    let(:optset) do
      optdata = option_set_data
      OptProc::OptionSet.new optdata
    end
    
    subject { optset }
    
    context "when one option" do
      def option_set_data
        optdata = Array.new
        optdata << {
          :tags => %w{ -a --abc },
          :set  => Proc.new { |x| }
        }
        optdata
      end
      
      it "should match the passed option" do
        should have(1).options
      end
    end

    context "when two options" do
      def option_set_data
        optdata = Array.new
        optdata << {
          :tags => %w{ -a --abc },
          :set  => Proc.new { |x| }
        }

        optdata << {
          :tags => %w{ -d --def },
          :set  => Proc.new { |x| }
        }

        optdata
      end

      it "with two passed options" do
        should have(2).options
      end
    end
  end

  describe "#process" do
    let(:optset) do
      optdata = option_set_data
      OptProc::OptionSet.new optdata
    end
    
    subject { optset }
    
    def process args
      optset.process args
    end
    
    context "when one option is defined" do
      def option_set_data
        @executed = false
        optdata = Array.new
        optdata << {
          :tags => %w{ -a --abc },
          :set  => Proc.new { @executed = true }
        }
        optdata
      end

      subject { @executed }

      it "should use the long arg" do
        process %w{ --abc }
        should be_true
      end  

      it "should use the short arg" do
        process %w{ -a }
        should be_true
      end

      it "should ignore invalid long arg" do
        process %w{ --def }
        should be_false
      end

      it "should ignore invalid short arg" do
        process %w{ -d }
        should be_false
      end

      it "should leave one unprocessed argument" do
        args = %w{ -a something }
        process args
        args.should have(1).items
        args[0].should eql 'something'
      end
    end

    context "when two options are defined" do
      def option_set_data
        optdata = Array.new
        optdata << {
          :tags => %w{ -a --abc },
          :set  => Proc.new { @abc = true }
        }
        @xyz = false
        optdata << {
          :tags => %w{ -x --xyz },
          :set  => Proc.new { @xyz = true }
        }
        optdata
      end

      def abc
        @abc
      end

      def xyz
        @xyz
      end

      describe "first option" do
        it "should use the long arg" do
          process %w{ --abc }
          abc.should be_true
          xyz.should be_false
        end  

        it "should use the short arg" do
          process %w{ -a }
          abc.should be_true
          xyz.should be_false
        end
      end

      describe "second option" do
        it "should use the long arg" do
          process %w{ --xyz }
          abc.should be_false
          xyz.should be_true
        end  

        it "should use the short arg" do
          process %w{ -x }
          abc.should be_false
          xyz.should be_true
        end
      end

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
      end
    end

    context "when number and short options are defined" do
      def option_set_data
        optdata = Array.new
        optdata << {
          :regexp => Regexp.new('^-(\d+)'),
          :arg => [ :integer ],
          :set  => Proc.new { |val| @abc = val }
        }
        @xyz = false
        optdata << {
          :tags => %w{ -x --xyz },
          :set  => Proc.new { |val| @xyz = true }
        }
        optdata
      end

      it "should split short args when number is first" do
        args = %w{ -123x }
        optset.process args
        @abc.should eql 123
        @xyz.should be_true
        args.should be_empty
      end

      it "should split short args when number is first" do
        args = %w{ -x123 }
        optset.process args
        @abc.should eql 123
        @xyz.should be_true
        args.should be_empty
      end
    end

    context "when options are incomplete" do
      def option_set_data
        @abc_executed = false
        optdata = Array.new
        optdata << {
          :tags => %w{ --abc },
          :set  => Proc.new { @abc_executed = true }
        }
        @abcdef_executed = false
        optdata << {
          :tags => %w{ --abcdef },
          :set  => Proc.new { @abcdef_executed = true }
        }
        @ghi_executed = false
        optdata << {
          :tags => %w{ --ghi },
          :set  => Proc.new { @ghi_executed = true }
        }
        optdata
      end

      def abc
        @abc_executed
      end

      def abcdef
        @abcdef_executed
      end

      def ghi
        @ghi_executed
      end

      it "should use the full unambiguous option" do
        args = %w{ --abc }
        process args
        abc.should be_true
        abcdef.should be_false
        ghi.should be_false
      end

      it "should use the short unambiguous option" do
        args = %w{ --gh }
        process args
        abc.should be_false
        abcdef.should be_false
        ghi.should be_true
      end

      it "should use the ambiguous option" do
        args = %w{ --ab }
        expect { process(args) }.to raise_error(RuntimeError, "ambiguous match of '--ab'; matches options: (--abc), (--abcdef)")
      end
    end

    context "when regexp" do
      def option_set_data
        @abc_value = nil
        optdata = Array.new
        optdata << {
          :res => %r{ ^ - ([1-9]\d*) $ }x,
          :set => Proc.new { |val| @abc_value = val },
        }
        optdata
      end

      subject { @abc_value }

      it "should match" do
        args = %w{ -123 }
        process args
        should be_a_kind_of(MatchData)
        @abc_value[1].should eql '123'
      end
    end

    context "when arguments contain double dash" do
    end

    context "when arguments contain double dash" do
      def option_set_data
        optdata = Array.new
        optdata << {
          :tags => %w{ -a --abc },
          :set  => Proc.new { @abc = true }
        }
        @xyz = false
        optdata << {
          :tags => %w{ -x --xyz },
          :set  => Proc.new { @xyz = true }
        }
        optdata
      end

      it "sets option preceding --" do
        args = %w{ --abc -- foo }
        optset.process args
        @abc.should == true
        @xyz.should == false
        args.should eql %w{ foo }
      end
    end
  end
end
