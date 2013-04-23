#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/synoption/set'
require 'ragol/synoption/option'
require 'support/option_sets'
require 'spec_helper'

describe Synoption::OptionSet do
  include Logue::Loggable, Synoption::OptionTestSets

  include_context "common optset tests"
  
  describe "#method" do
    describe "OptionSet subclass" do
      subject { create_def_option_set.process Array.new }

      valid_methods = [ :delta, :echo, :foxtrot ]
      invalid_methods = [ :bfd ]
      
      it_behaves_like "defined methods", valid_methods, invalid_methods
    end
  end

  context "when one option unsets another" do
    def process args
      @results = create_abc_option_set(:unsets => :bravo).process args
    end

    subject { @results }

    it_behaves_like "an option set with unset options"
  end

  context ":has_option" do
    context "when direct subclass of OptionSet" do
      def process args
        @results = create_def_option_set.process args
      end

      subject { @results }

      context "when arguments are valid" do
        before :all do
          process %w{ --echo foo }
        end

        its(:delta) { should eql 317 }
        its(:echo) { should eql 'foo' }
        its(:foxtrot) { should be_false }
      end

      describe "multiple invocations" do
        context "first invocation" do
          before :all do
            process %w{ --echo foo }
          end
          
          its(:delta) { should eql 317 }
          its(:echo) { should eql 'foo' }
          its(:foxtrot) { should be_false }
        end
        
        context "second invocation" do
          before :all do
            process %w{ --foxtrot bar }
          end
          
          its(:delta) { should eql 317 }
          its(:echo) { should eql 'default default' }
          its(:foxtrot) { should be_true }
        end
      end
    end

    context "when multiple subclasses of OptionSet" do
      def process args
        @results = create_defgh_option_set.process args
      end

      subject { @results }

      describe "#process" do
        context "when arguments are valid" do
          before :all do
            process %w{ --echo foo }
          end
          
          its(:delta) { should eql 317 }
          its(:echo) { should eql 'foo' }
          its(:foxtrot) { should be_false }
          its(:golf) { should be_nil }
          its(:hotel) { should eql 8.79 }
        end

        describe "multiple invocations" do
          context "first invocation" do
            before :all do
              process %w{ --echo foo }
            end
            
            its(:delta) { should eql 317 }
            its(:echo) { should eql 'foo' }
            its(:foxtrot) { should be_false }
            its(:golf) { should be_nil }
            its(:hotel) { should eql 8.79 }
          end

          context "second invocation" do
            before :all do
              process %w{ --hotel 8.881 bar }
            end
            
            its(:delta) { should eql 317 }
            its(:echo) { should eql 'default default' }
            its(:foxtrot) { should be_false }
            its(:golf) { should be_nil }
            its(:hotel) { should eql 8.881 }
          end
        end
      end
    end
  end
end
