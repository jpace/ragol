#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optproc'

describe OptProc::Option do
  before :all do
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end
  
  describe :match_tag do
    before :each do
      @opt = OptProc::Option.new :tags => %w{ --after-context -A }, :arg => [ :integer ]
    end

    def run_match tag
      @opt.match [ tag ]
    end

    describe "exact match" do
      it "long tag" do
        run_match('--after-context').should == 1.0
      end

      it "long tag with =" do
        run_match('--after-context=3').should == 1.0
      end

      it "short tag" do
        run_match('-A').should == 1.0
      end
    end
    
    describe "non match" do
      it "wrong long tag" do
        run_match('--before-context').should be_nil
      end

      it "wrong short tag" do
        run_match('-b').should be_nil
      end
    end
    
    describe "is case sensitive" do
      it "long tag" do
        run_match('--After-Context').should be_nil
      end

      it "short tag" do
        run_match('-a').should be_nil
      end
    end

    describe "partial match" do
      it "long tag" do
        run_match('--after-cont').should == 0.12
      end

      it "long tag with =" do
        run_match('--after-cont=3').should == 0.12
      end
    end
  end

  describe :match_tag do
    before :each do
      @ctx = nil
      @opt = OptProc::Option.new(:res  => %r{ ^ - ([1-9]\d*) $ }x,
                                 :arg  => [ :optional, :integer ],
                                 :set  => Proc.new { |val| @ctx = val })
    end

    def run_match tag
      @opt.match [ tag ]
    end

    describe "regexp option" do
      it "one digit" do
        run_match('-1').should == 1.0
      end

      it "two digits" do
        run_match('-42').should == 1.0
      end

      it "not numeric" do
        run_match('-a').should be_nil
      end
    end
  end

  describe :set_value do
    describe "float option" do
      before :each do
        @after = nil
        @opt = OptProc::Option.new(:tags => %w{ --after-context -A },
                              :arg  => [ :required, :float ],
                              :set  => Proc.new { |val| @after = val })
      end
      
      it "sets from long tag" do
        @opt.set_value %w{ --after-context 3 }
        @after.should eql 3.0
      end

      it "sets from long tag = " do
        @opt.set_value %w{ --after-context=3 }
        @after.should eql 3.0
      end

      it "sets from short option" do
        @opt.set_value %w{ -A 3 }
        @after.should eql 3.0
      end
    end

    describe "regexp value" do
      before :each do
        @range_start = nil
        @opt = OptProc::Option.new(:tags => %w{ --after },
                                   :arg  => [ :required, :regexp, %r{ ^ (\d+%?) $ }x ],
                                   :set  => Proc.new { |md| @range_start = md && md[1] })
      end

      it "sets from single digit number" do
        @opt.set_value %w{ --after 5 }
        @range_start.should == '5'
      end

      it "sets from single digit number %" do
        @opt.set_value %w{ --after 5% }
        @range_start.should == '5%'
      end

      it "sets from two digit number" do
        @opt.set_value %w{ --after 10 }
        @range_start.should == '10'
      end

      it "sets from two digit number %" do
        @opt.set_value %w{ --after 10% }
        @range_start.should == '10%'
      end

      it "does not set from alpha" do
        @opt.set_value %w{ --after x }
        @range_start.should be_nil
      end
    end
  end
end
