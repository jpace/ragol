#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optset'

describe OptProc::OptionSet do
  before :all do
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end

  describe "initializes" do
    before :each do
      @optdata = Array.new
      @optdata << {
        :tags => %w{ -a --abc },
        :arg  => [ :string ],
        :set  => Proc.new { |x| }
      }
    end

    it "with one passed option" do
      set = OptProc::OptionSet.new @optdata
      set.should have(1).options
    end

    it "with two passed options" do
      @optdata << {
        :tags => %w{ -d --def },
        :arg  => [ :string ],
        :set  => Proc.new { |x| }
      }
      set = OptProc::OptionSet.new @optdata
      set.should have(2).options
    end
  end

  describe "processes one option" do
    before :each do
      @executed = false
      optdata = Array.new
      optdata << {
        :tags => %w{ -a --abc },
        :set  => Proc.new { @executed = true }
      }
      @set = OptProc::OptionSet.new optdata
    end

    it "uses long arg" do
      @set.process_option %w{ --abc }
      @executed.should be_true
    end  

    it "uses short arg" do
      @set.process_option %w{ -a }
      @executed.should be_true
    end

    it "ignores invalid long arg" do
      @set.process_option %w{ --def }
      @executed.should be_false
    end

    it "ignores invalid short arg" do
      @set.process_option %w{ -d }
      @executed.should be_false
    end

    it "leaves one unprocessed argument" do
      args = %w{ -a something }
      @set.process_option args
      args.should have(1).items
      args[0].should eql 'something'
    end
  end

  describe "processes two options" do
    before :each do
      @abc_executed = false
      optdata = Array.new
      optdata << {
        :tags => %w{ -a --abc },
        :set  => Proc.new { @abc_executed = true }
      }
      @def_executed = false
      optdata << {
        :tags => %w{ -d --def },
        :set  => Proc.new { @def_executed = true }
      }
      @set = OptProc::OptionSet.new optdata
    end

    describe "first option" do
      it "uses long arg" do
        @set.process_option %w{ --abc }
        @abc_executed.should be_true
        @def_executed.should be_false
      end  

      it "uses short arg" do
        @set.process_option %w{ -a }
        @abc_executed.should be_true
        @def_executed.should be_false
      end
    end

    describe "second option" do
      it "uses long arg" do
        @set.process_option %w{ --def }
        @abc_executed.should be_false
        @def_executed.should be_true
      end  

      it "uses short arg" do
        @set.process_option %w{ -d }
        @abc_executed.should be_false
        @def_executed.should be_true
      end
    end

    describe "both options" do
      it "uses long arg for both options" do
        args = %w{ --abc --def }
        @set.process_option args
        @abc_executed.should be_true
        @def_executed.should be_false
        args.should have(1).items

        @set.process_option args
        @abc_executed.should be_true
        @def_executed.should be_true
        args.should be_empty
      end  

      it "uses short arg for both options" do
        args = %w{ -a -d }
        @set.process_option args
        @abc_executed.should be_true
        @def_executed.should be_false
        args.should have(1).items

        @set.process_option args
        @abc_executed.should be_true
        @def_executed.should be_true
        args.should be_empty
      end  

      it "uses long arg for first, short for second" do
        args = %w{ --abc -d }
        @set.process_option args
        @abc_executed.should be_true
        @def_executed.should be_false
        args.should have(1).items

        @set.process_option args
        @abc_executed.should be_true
        @def_executed.should be_true
        args.should be_empty
      end  

      it "uses short arg for first, long for second" do
        args = %w{ -a --def }
        @set.process_option args
        @abc_executed.should be_true
        @def_executed.should be_false
        args.should have(1).items

        @set.process_option args
        @abc_executed.should be_true
        @def_executed.should be_true
        args.should be_empty
      end  

      it "splits short args" do
        args = %w{ -ad }
        @set.process_option args
        @abc_executed.should be_true
        @def_executed.should be_false

        # not necessarily: we might change this to process both at once.
        args.should have(1).items

        @set.process_option args
        @abc_executed.should be_true
        @def_executed.should be_true
        args.should be_empty
      end
    end
  end

  describe "processes incomplete options" do
    before :each do
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
      @set = OptProc::OptionSet.new optdata
    end

    it "uses full unambiguous option" do
      args = %w{ --abc }
      @set.process_option args
      @abc_executed.should be_true
      @abcdef_executed.should be_false
      @ghi_executed.should be_false
    end

    it "uses short unambiguous option" do
      args = %w{ --gh }
      @set.process_option args
      @abc_executed.should be_false
      @abcdef_executed.should be_false
      @ghi_executed.should be_true
    end

    it "uses ambiguous option" do
      args = %w{ --ab }
      expect { @set.process_option(args) }.to raise_error(RuntimeError, "ambiguous match of '--ab'; matches options: (--abc), (--abcdef)")
    end
  end
end
