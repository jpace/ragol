#!/usr/bin/ruby -w
# -*- ruby -*-

shared_context "common optset tests" do
  describe "#method" do
    describe "OptionSet class (not subclass)" do
      subject { create_abc_option_set.process Array.new }

      valid_methods = [ :alpha, :bravo, :charlie ]
      invalid_methods = [ :bfd ]
      
      it_behaves_like "defined methods", valid_methods, invalid_methods
    end
  end

  context "when options are isolated" do
    def process args
      @results = create_abc_option_set.process args
    end

    subject(:results) { @results }

    it_behaves_like "an option set"
  end

  context "when options contain short arguments" do
    def process args
      @results = create_fij_option_set.process args
    end
    
    subject { @results }
    
    it_behaves_like "an option set with short arguments"
  end

  context "when options partially match" do
    def process args
      @results = create_dd_option_set.process args
    end

    subject { @results }

    it_behaves_like "an option set with partially matching options"
  end
end
