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
  end
end
