#!/usr/bin/ruby -w
# -*- ruby -*-

shared_examples "a ragol option set" do
  context "when one option unsets another" do
    def process args
      @results = create_abc_option_set(:unsets => 'bravo').process args
    end

    subject { @results }

    it_behaves_like "an option set with unset options"
  end

  context "regexp with value type conversion" do
    describe "#process" do
      context "when regexp" do
        def option_data
          @value = nil
          optdata = Array.new
          optdata << {
            :res => %r{ ^ - ([1-9]\d*) $ }x,
            :set => Proc.new { |val| @value = val },
          }
          optdata
        end

        subject { @value }

        it "should match" do
          args = %w{ -123 }
          process args
          should eql '123'
        end
      end
    end
  end

  context "regexp option with another option" do
    describe "#process" do
      def option_data
        optdata = Array.new

        @context = nil
        optdata << {
          :tags   => %w{ -C --context },
          :regexp => %r{ ^ - ([1-9]\d*) $ }x,
          :arg    => [ :optional, :integer ],
          :set    => Proc.new { |val| @context = val || 2 },
        }
        @abc = nil
        optdata << {
          :tags => %w{ -a --abc },
          :set  => Proc.new { |v| @abc = v }
        }
        
        optdata
      end
      
      it "takes a tag argument" do
        process %w{ --context 17 }
        @context.should eq 17
      end

      it "takes a tag argument" do
        process %w{ -C 17 }
        @context.should eq 17
      end

      it "ignores missing tag argument" do
        process %w{ --context }
        @context.should eq 2
      end

      it "takes the regexp value (not argument)" do
        process %w{ -17 }
        @context.should eq 17
      end

      it "takes the regexp value with following -o" do
        args = %w{ -17 -a }
        process args
        @context.should eq 17
        @abc.should be_true
        args.should be_empty
      end

      it "takes the regexp value with joined -o" do
        args = %w{ -17a }
        process args
        @context.should eq 17
        @abc.should be_true
        args.should be_empty
      end
    end
  end

  context "regexp with value type conversion" do
    describe "#process" do
      def option_data
        optdata = Array.new

        @context = nil
        optdata << {
          :regexp => %r{ ^ - ([1-9]\d*) $ }x,
          :valuetype => :integer,
          :set    => Proc.new { |val| @context = val || 2 },
        }
        
        optdata
      end
      
      it "takes the regexp value (not argument)" do
        process %w{ -17 }
        @context.should eq 17
      end
    end
  end
end
