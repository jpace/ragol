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

  describe "with argument" do
    before :each do
      optdata = Array.new

      @string_value = nil
      optdata << {
        :tags => %w{ --str },
        :arg  => [ :string ],
        :set  => Proc.new { |v| @string_value = v }
      }

      @integer_value = nil
      optdata << {
        :tags => %w{ --int },
        :arg  => [ :integer ],
        :set  => Proc.new { |v| @integer_value = v }
      }

      @iopt_value = nil
      optdata << {
        :tags => %w{ --iopt },
        :arg  => [ :integer, :optional ],
        :set  => Proc.new { |v| @iopt_value = v }
      }

      @float_value = nil
      optdata << {
        :tags => %w{ --flt },
        :arg  => [ :float ],
        :set  => Proc.new { |val| @float_value = val },
      }
      
      @set = OptProc::OptionSet.new optdata
    end

    it "takes a required string" do
      args = %w{ --str xyz }
      @set.process_option args
      @string_value.should eql 'xyz'
    end

    it "takes a required integer" do
      args = %w{ --int 1 }
      @set.process_option args
      @integer_value.should eql 1
    end

    it "rejects a non-integer" do
      pending "not yet implemented"
      args = %w{ --int 1.0 }
      @set.process_option args
      @integer_value.should be_nil
    end

    it "takes an optional integer" do
      args = %w{ --iopt 1 }
      @set.process_option args
      @iopt_value.should eql 1
    end

    it "ignores a missing optional integer" do
      args = %w{ --iopt }
      @set.process_option args
      @iopt_value.should be_nil
    end

    it "takes a required float" do
      args = %w{ --flt 3.1415 }
      @set.process_option args
      @float_value.should eql 3.1415
    end
  end

  describe "with regexp" do
    describe "without datatype conversion" do
      before :each do
        optdata = Array.new

        @abc_value = nil
        optdata << {
          :res  => %r{ ^ - ([1-9]\d*) $ }x,
          :set  => Proc.new { |val| @abc_value = val },
        }

        @set = OptProc::OptionSet.new optdata
      end

      it "string becomes matchdata" do
        args = %w{ -123 }
        @set.process_option args
        @abc_value.should be_a_kind_of(MatchData)
        @abc_value[1].should eql '123'
      end
    end
    
    describe "with datatype conversion" do
      before :each do
        optdata = Array.new

        @integer_value = nil
        optdata << {
          :res  => %r{ ^ - (1\d*) $ }x,
          :arg  => [ :integer ],
          :set  => Proc.new { |val| @integer_value = val },
        }

        @string_value = nil
        optdata << {
          :res  => %r{ ^ - (2\d*) $ }x,
          :arg  => [ :string ],
          :set  => Proc.new { |val| @string_value = val },
        }
        
        @set = OptProc::OptionSet.new optdata
      end

      it "converts string" do
        args = %w{ -123 }
        @set.process_option args
        @integer_value.should eql 123
      end

      it "converts integer" do
        args = %w{ -234 }
        @set.process_option args
        @string_value.should eql '234'
      end
    end
  end
end
