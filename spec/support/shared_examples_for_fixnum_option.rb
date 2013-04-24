#!/usr/bin/ruby -w
# -*- ruby -*-

shared_examples "a fixnum option" do
  valid_tags = %w{ -d --delta }
  
  valid_tags.each do |tag|
    context "with valid tag #{tag}" do
      before :all do
        process_option [ tag, '434' ]
      end

      it "should have the results" do
        @results.delta.should == 434
      end

      it "should have no unprocessed arguments" do
        @results.unprocessed.should be_empty
      end

      it "should have the value" do
        value.should eq 434
      end
    end

    it "raises error without required argument for tag #{tag}" do
      args = [ tag ]
      expect { process_option(args) }.to raise_error(RuntimeError, "value expected for option: -d, --delta")
    end

    it "rejects a non-integer" do
      args = [ tag, '1.0' ]
      expect { process_option(args) }.to raise_error(RuntimeError, "invalid argument '1.0' for option: -d, --delta")
    end
  end

  it "rejects a non-integer as --delta=" do
    args = %w{ --delta=1.0 }
    expect { process_option(args) }.to raise_error(RuntimeError, "invalid argument '1.0' for option: -d, --delta")
  end

  it "rejects a non-integer as -d" do
    args = %w{ -d 1.0 }
    expect { process_option(args) }.to raise_error(RuntimeError, "invalid argument '1.0' for option: -d, --delta")
  end
end
