#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/option'
require 'ragol/optproc/common'
require 'ragol/optproc/args'
require 'ragol/common'

describe OptProc::OptionArguments do
  describe ".convert_arguments" do
    def convert_arguments old_arguments
      @new_arguments = OptProc::OptionArguments.new old_arguments
    end

    subject { @new_arguments }

    context "when tags only" do
      before :all do
        old_arguments = {
          :tags => [ '--foo', '-b' ],
        }
        convert_arguments old_arguments
      end

      it "should have :tags" do
        subject[:tags].should eql [ '--foo', '-b' ]
      end

      it "should not have :regexps" do
        subject[:regexps].should be_nil
      end
    end

    context "when regexps tags only" do
      [ :regexps, :regexp, :res, :re ].each do |field|
        context "when field is '#{field.inspect}'" do
          before :all do
            old_arguments = {
              field => Regexp.new('^--(\d+)$'),
            }
            convert_arguments old_arguments
          end

          it "should not have :tags" do
            subject[:tags].should be_nil
          end

          it "should have :regexps" do
            subject[:regexps].should eql Regexp.new('^--(\d+)$')
          end
        end
      end
    end

    context "when both tags and regexps" do
      before :all do
        old_arguments = {
          :tags => [ '--foo', '-b' ],
          :regexps => [ Regexp.new('^--(\d+)$') ],
        }
        convert_arguments old_arguments
      end

      it "should have :tags" do
        subject[:tags].should eql [ '--foo', '-b' ]
      end

      it "should have :regexps" do
        subject[:regexps].should eql [ Regexp.new('^--(\d+)$') ]
      end
    end

    context "when argument value is explicitly required" do
      before :all do
        old_arguments = {
          :arg => [ :required ],
        }
        convert_arguments old_arguments
      end

      it "should have :takesvalue" do
        subject[:takesvalue].should == true
      end
    end

    context "when argument value is optional" do
      before :all do
        old_arguments = {
          :arg => [ :optional ],
        }
        convert_arguments old_arguments
      end

      it "should have :takesvalue as :optional" do
        subject[:takesvalue].should == :optional
      end
    end

    context "when argument value is none" do
      before :all do
        old_arguments = {
          :arg => [ :none ],
        }
        convert_arguments old_arguments
      end

      it "should not have :takesvalue" do
        subject[:takesvalue].should == false
      end
    end

    context "when argument value is not specified" do
      before :all do
        old_arguments = {
          :arg => [ ],
        }
        convert_arguments old_arguments
      end

      it "should not have :takesvalue" do
        subject[:takesvalue].should == false
      end
    end

    context "when arg is unspecified" do
      before :all do
        old_arguments = {
        }
        convert_arguments old_arguments
      end

      it "should not have :takesvalue" do
        subject[:takesvalue].should == nil
      end

      it "should have no value type" do
        subject[:valuetype].should be_nil
      end
    end

    shared_examples "value type" do |valuetype, converted_type = valuetype|
      context "when argument value type is #{valuetype.inspect}" do
        before :all do
          old_arguments = {
            :arg => [ valuetype ]
          }
          convert_arguments old_arguments
        end

        it "should have :takesvalue" do
          subject[:takesvalue].should == true
        end

        it "should have valuetype #{converted_type.inspect}" do
          subject[:valuetype].should == converted_type
        end
      end
    end

    [ :fixnum, :float, :string, :regexp ].each do |valuetype|
      include_examples "value type", valuetype
    end
    
    include_examples "value type", :integer, :fixnum

    context "when argument value type is boolean" do
      before :all do
        old_arguments = {
          :arg => [ :boolean ]
        }
        convert_arguments old_arguments
      end

      it "should not have :takesvalue" do
        subject[:takesvalue].should == false
      end

      it "should have valuetype :boolean" do
        subject[:valuetype].should == :boolean
      end
    end

    context "when set is specified" do
      before :all do
        @proc = Proc.new { }
        old_arguments = {
          :set => @proc
        }
        convert_arguments old_arguments
      end

      it "should have :process" do
        subject[:process].should eql @proc
      end
    end

    context "when arguments are the new format" do
      before :all do
        process = Proc.new { }
        postproc = Proc.new { }
        @orig_arguments = {
          :regexps => [ Regexp.new('--fo+'), Regexp.new('--ba*r') ],
          :tags => [ '--foo', '-b' ],
          :rcnames => [ 'foo', 'foobar' ],
          :takesvalue => :optional,
          :valuetype => :float,
          :default => 8899,
          :process => process,
          :postproc => postproc
        }
        convert_arguments @orig_arguments
      end

      [ :regexps, :tags, :rcnames, :takesvalue, :valuetype, :default, :process, :postproc ].each do |field|
        it "should match field #{field}" do
          subject[field].should eql @orig_arguments[field]
        end
      end
    end
  end
end
