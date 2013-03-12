#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optproc'

describe OptProc::Option do
  before :all do
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end

  describe "string option" do
    before :each do
      optdata = Array.new

      @string_value = nil
      optdata << {
        :tags => %w{ --str },
        :arg  => [ :string ],
        :set  => Proc.new { |v| @string_value = v }
      }

      @sopt_value = nil
      optdata << {
        :tags => %w{ --sopt },
        :arg  => [ :string, :optional ],
        :set  => Proc.new { |v| @sopt_value = v }
      }

      @set = OptProc::OptionSet.new optdata
    end

    def process args
      @set.process_option args
    end

    it "takes a required argument" do
      args = %w{ --str xyz }
      process args
      @string_value.should eq 'xyz'
    end

    it "takes a required argument with =" do
      args = %w{ --str=xyz }
      process args
      @string_value.should eq 'xyz'
    end

    it "takes an optional argument" do
      args = %w{ --sopt xyz }
      process args
      @sopt_value.should eq 'xyz'
    end

    it "takes an optional argument with =" do
      args = %w{ --sopt=xyz }
      process args
      @sopt_value.should eq 'xyz'
    end

    it "ignores a missing optional argument" do
      args = %w{ --sopt }
      process args
      @sopt_value.should be_nil
    end

    it "optional ignores a following --xyz option" do
      args = %w{ --sopt --xyz }
      process args
      @sopt_value.should be_nil
    end

    it "optional ignores a following -x option" do
      args = %w{ --sopt -x }
      process args
      @sopt_value.should be_nil
    end
  end

  describe "integer option" do
    before :each do
      optdata = Array.new

      @integer_value = nil
      optdata << {
        :tags => %w{ --int },
        :arg  => [ :integer ],
        :set  => Proc.new { |v| @integer_value = v }
      }

      @iopt_value = nil
      optdata << {
        :tags => %w{ --iopt },
        :arg  => [ :integer, :optional ],
        :set  => Proc.new { |v| @iopt_value = v }
      }
      
      @set = OptProc::OptionSet.new optdata
    end

    def process args
      @set.process_option args
    end

    it "takes a required argument" do
      args = %w{ --int 1 }
      process args
      @integer_value.should eq 1
    end

    # it "rejects a non-integer" do
    #   pending "not yet implemented"
    #   args = %w{ --int 1.0 }
    #   process args
    #   @integer_value.should be_nil
    # end

    it "takes an optional argument" do
      args = %w{ --iopt 1 }
      process args
      @iopt_value.should eq 1
    end

    it "ignores a missing optional argument" do
      args = %w{ --iopt }
      process args
      @iopt_value.should be_nil
    end
  end

  describe "float option" do
    before :each do
      optdata = Array.new

      @float_value = nil
      optdata << {
        :tags => %w{ --flt },
        :arg  => [ :float ],
        :set  => Proc.new { |val| @float_value = val }
      }
      
      @set = OptProc::OptionSet.new optdata
    end

    def process args
      @set.process_option args
    end

    it "takes a required argument" do
      args = %w{ --flt 3.1415 }
      process args
      @float_value.should eq 3.1415
    end

    it "takes a required integer argument" do
      args = %w{ --flt 3 }
      process args
      @float_value.should eq 3
    end
  end
  
  describe "boolean option" do
    before :each do
      optdata = Array.new

      @boolean_value = nil
      optdata << {
        :tags => %w{ --bool },
        :arg  => [ :boolean ],
        :set  => Proc.new { |val| @boolean_value = val }
      }
      
      @set = OptProc::OptionSet.new optdata
    end

    def process args
      @set.process_option args
    end

    def test_boolean exp, args
      process args
      @boolean_value.should eq exp
    end
    
    %w{ true yes on }.each do |val|
      it "takes #{val} as true" do
        test_boolean true, [ '--bool', val ]
      end
    end
    
    %w{ false no off }.each do |val|
      it "takes #{val} as false" do
        test_boolean false, [ '--bool', val ]
      end
    end
  end

  describe "with regexp" do
    before :each do
      optdata = Array.new

      @integer_value = nil
      optdata << {
        :res  => %r{ ^ - (1\d*) $ }x,
        :arg  => [ :integer ],
        :set  => Proc.new { |val| @integer_value = val },
      }

      @string_value = nil
      optdata << {
        :res  => %r{ ^ - (2\d*) $ }x,
        :arg  => [ :string ],
        :set  => Proc.new { |val| @string_value = val },
      }
      
      @set = OptProc::OptionSet.new optdata
    end

    it "converts string" do
      args = %w{ -123 }
      @set.process_option args
      @integer_value.should eq 123
    end

    it "converts integer" do
      args = %w{ -234 }
      @set.process_option args
      @string_value.should eq '234'
    end
  end
end
