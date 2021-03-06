#!/usr/bin/ruby -w
# -*- ruby -*-

shared_examples "an option set" do
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

      its(:alpha) { should eql 'bar' }
      its(:charlie) { should be_nil }
      its(:bravo) { should be_nil }
      its(:unprocessed) { should eql %w{ --charlie foo } }
    end
  end

  def readrc(*lines)
    @results = create_abc_option_set.read_rclines lines
  end

  describe "#readrc" do
    before :all do
      readrc 'alpha: bar'
    end
    
    its(:alpha) { should eql 'bar' }
    its(:charlie) { should be_nil }
    its(:bravo) { should be_nil }
  end
end

shared_examples "an option set with short arguments" do
  describe "#process" do
    context "with separated arguments" do
      before :all do
        process %w{ -f -i }
      end

      its(:foxtrot) { should be_true }
      its(:india) { should be_true }
      its(:juliet) { should be_nil }
    end

    context "with joined arguments" do
      before :all do
        process %w{ -fi }
      end

      its(:foxtrot) { should be_true }
      its(:india) { should be_true }
      its(:juliet) { should be_nil }
    end

    context "with number and short options" do
      %w{ -36if -36fi }.each do |arg|
        before :all do
          process [ arg ]
        end
        
        its(:foxtrot) { should be_true }
        its(:india) { should be_true }
        its(:juliet) { should eql '36' }
      end
    end

    context "with joined arguments and other arguments" do
      before :all do
        process %w{ -fi foo bar }
      end

      its(:foxtrot) { should be_true }
      its(:india) { should be_true }
      its(:juliet) { should be_nil }
      its(:unprocessed) { should eql %w{ foo bar } }
    end
  end
end

shared_examples "an option set with unset options" do
  describe "#process" do
    context "when there is no option to unset" do
      before :all do
        process %w{ --bravo foo }
      end

      its(:alpha) { should be_nil }
      its(:bravo) { should eql 'foo' }
      its(:charlie) { should be_nil }
    end

    context "when there is only an option to unset" do
      before :all do
        process %w{ --charlie bar }
      end

      its(:alpha) { should be_nil }
      its(:bravo) { should be_nil }
      its(:charlie) { should eql 'bar' }
    end

    context "when the option order is the unset option, then the option to be unset" do
      before :all do
        process %w{ --charlie baz --bravo foo }
      end

      its(:alpha) { should be_nil }
      its(:bravo) { should be_nil }
      its(:charlie) { should eql 'baz' }
    end

    context "when the option order is the option to be unset, then the unset option" do
      before :all do
        process %w{ --bravo foo --charlie bar }
      end

      its(:alpha) { should be_nil }
      its(:bravo) { should be_nil }
      its(:charlie) { should eql 'bar' }
    end
  end
end

shared_examples "an option set with partially matching options" do
  describe "#process" do
    context "when arguments are full" do
      before :all do
        process %w{ --delay 44 --delta 6 }
      end
      
      its(:delay) { should eql '44' }
      its(:delta) { should eql 6 }
    end

    context "when arguments are partial" do
      before :all do
        process %w{ --dela 144 --delt 37 }
      end
      
      its(:delay) { should eql '144' }
      its(:delta) { should eql 37 }
    end

    context "when arguments are conflicting partial" do
      it "should error on ambiguous options" do
        args = %w{ --del 144 --del 37 }
        expect { process(args) }.to raise_error(RuntimeError, "ambiguous match of '--del'; matches options: (-d, --delta), (-y, --delay)")
      end
    end
  end
end

shared_examples "an option set containing an option with an optional value" do
  %w{ -k --kilo }.each do |val|
    it "matches #{val} with no following argument" do
      process [ val ]
      @results.kilo.should == nil
      @results.india.should be_false
      @results.unprocessed.should be_empty
    end

    it "matches #{val} with following argument" do
      process [ val, 'abc' ]
      @results.kilo.should eql 'abc'
      @results.india.should be_false
      @results.unprocessed.should be_empty
    end

    it "matches #{val} with following -i" do
      process [ val, '-i' ]
      @results.kilo.should eql true
      @results.india.should be_true
      @results.unprocessed.should be_empty
    end

    it "matches #{val} with following --india" do
      process [ val, '--india' ]
      @results.kilo.should eql true
      @results.india.should be_true
      @results.unprocessed.should be_empty
    end
  end

  it "matches --kilo=value with no argument" do
    process %w{ --kilo=xyz }
    @results.kilo.should eql 'xyz'
    @results.india.should be_false
    @results.unprocessed.should be_empty
  end
end
