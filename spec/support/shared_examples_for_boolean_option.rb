#!/usr/bin/ruby -w
# -*- ruby -*-

shared_examples "a boolean option" do
  describe "#process" do
    valid_tags = %w{ -f --foxtrot }
    
    valid_tags.each do |tag|
      context "with valid tag #{tag}" do
        before :all do
          process_option [ tag, 'foo' ]
        end

        it "should have the results" do
          @results.foxtrot.should == true
        end

        it "should have an unprocessed argument" do
          @results.unprocessed.should eql %w{ foo }
        end

        it "should have the value" do
          value.should == true
        end
      end
    end
  end
  
  describe "#to_doc" do
    it "should have documentation" do
      sio = StringIO.new
      option.to_doc sio
      exp = String.new
      exp << "  -f, --foxtrot            : a dance\n"
      sio.string.should eql exp
    end
  end
end
