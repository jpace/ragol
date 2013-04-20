#!/usr/bin/ruby -w
# -*- ruby -*-

shared_examples "a float option" do
  valid_tags = %w{ -h --hotel }
  
  valid_tags.each do |tag|
    context "with valid tag #{tag}" do
      [ 3.1415, 3 ].each do |num|
        context "with argument type #{num.class}" do
          before :all do
            process_option [ tag, num.to_s ]
          end

          it "should have the results" do
            @results.hotel.should == num
          end

          it "should have no unprocessed arguments" do
            @results.unprocessed.should be_empty
          end

          it "should have the value" do
            value.should eq num
          end
        end
      end
    end
  end

  def expect_invalid_arg arg, args
    expect { process_option(args) }.to raise_error(RuntimeError, "invalid argument '#{arg}' for option: -h, --hotel")
  end

  it "rejects a non-float string" do
    expect_invalid_arg 'foobar', %w{ --hotel foobar }
  end

  it "rejects a non-float string as =" do
    expect_invalid_arg 'foobar', %w{ --hotel=foobar }
  end

  it "rejects a non-float string as -h" do
    expect_invalid_arg 'foobar', %w{ -h foobar }
  end

  it "rejects a non-float number" do
    expect_invalid_arg '1.3.5', %w{ --hotel 1.3.5 }
  end

  it "rejects a non-float number as =" do
    expect_invalid_arg '1.3.5', %w{ --hotel=1.3.5 }
  end

  it "rejects a non-float number as -h" do
    expect_invalid_arg '1.3.5', %w{ -h 1.3.5 }
  end
end
