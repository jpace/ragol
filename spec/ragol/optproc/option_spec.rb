#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optproc'

describe OptProc::Option do
  before :all do
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end

  def create_set optdata
    @set = OptProc::OptionSet.new optdata
  end

  def process args
    @set.process_option args
  end

  before do
    optdata = Array.new
    create_option_data optdata
    create_set optdata
  end

  describe "string option" do
    describe "required (implicit)" do
      def create_option_data optdata
        @string_value = nil
        optdata << {
          :tags => %w{ --str },
          :arg  => [ :string ],
          :set  => Proc.new { |v| @string_value = v }
        }
      end

      subject { @string_value }

      it "takes an argument" do
        process %w{ --str xyz }
        should eq 'xyz'
      end

      it "takes an argument with =" do
        process %w{ --str=xyz }
        should eq 'xyz'
      end

      it "takes an argument matching tag" do
        process %w{ --str -foo }
        should eq '-foo'
      end

      it "expects an argument" do
        args = %w{ --str }
        expect { process args }.to raise_error(RuntimeError, "value expected for option: --str")
      end
    end

    describe "required (explicit)" do
      def create_option_data optdata
        @str_value = nil
        optdata << {
          :tags => %w{ --str },
          :arg  => [ :string, :required ],
          :set  => Proc.new { |x| @str_value = x }
        }
      end

      subject { @str_value }

      it "takes the argument" do
        args = %w{ --str foo }
        process args
        should eql 'foo'
        args.should have(0).items
      end

      it "expects an argument" do
        args = %w{ --str }
        expect { process args }.to raise_error(RuntimeError, "value expected for option: --str")
      end
    end

    describe "optional" do
      def create_option_data optdata
        @sopt_value = nil
        optdata << {
          :tags => %w{ --sopt },
          :arg  => [ :string, :optional ],
          :set  => Proc.new { |v| @sopt_value = v }
        }
      end

      subject { @sopt_value }

      it "takes an argument" do
        process %w{ --sopt xyz }
        should eq 'xyz'
      end

      it "takes an argument with =" do
        process %w{ --sopt=xyz }
        should eq 'xyz'
      end

      it "ignores a missing argument" do
        process %w{ --sopt }
        should be_nil
      end

      it "ignores a following --xyz option" do
        process %w{ --sopt --xyz }
        should be_nil
      end

      it "ignores a following -x option" do
        process %w{ --sopt -x }
        should be_nil
      end
    end
  end

  describe "integer option" do
    describe "required (implicit)" do
      def create_option_data optdata
        @integer_value = nil
        optdata << {
          :tags => %w{ --int },
          :arg  => [ :integer ],
          :set  => Proc.new { |v| @integer_value = v }
        }
      end

      subject { @integer_value }

      it "takes an argument" do
        process %w{ --int 1 }
        should eq 1
      end

      it "rejects a non-integer" do
        args = %w{ --int 1.0 }
        expect { process args }.to raise_error(RuntimeError, "invalid argument '1.0' for option: --int")
        should be_nil
      end

      it "rejects a non-integer as =" do
        args = %w{ --int=1.0 }
        expect { process args }.to raise_error(RuntimeError, "invalid argument '1.0' for option: --int")
        should be_nil
      end
    end

    describe "optional" do
      def create_option_data optdata
        @iopt_value = nil
        optdata << {
          :tags => %w{ --iopt },
          :arg  => [ :integer, :optional ],
          :set  => Proc.new { |v| @iopt_value = v }
        }
      end

      subject { @iopt_value }

      it "takes an argument" do
        process %w{ --iopt 1 }
        should eq 1
      end

      it "takes an argument as =" do
        process %w{ --iopt=1 }
        should eq 1
      end

      it "ignores a missing argument" do
        process %w{ --iopt }
        should be_nil
      end

      it "rejects a non-integer argument" do
        args = %w{ --iopt 1.0 }
        expect { process args }.to raise_error(RuntimeError, "invalid argument '1.0' for option: --iopt")
        should be_nil
      end

      it "rejects a non-integer argument as =" do
        args = %w{ --iopt=1.0 }
        expect { process args }.to raise_error(RuntimeError, "invalid argument '1.0' for option: --iopt")
        should be_nil
      end
    end
  end

  describe "float option" do
    def create_option_data optdata
      @float_value = nil
      optdata << {
        :tags => %w{ --flt },
        :arg  => [ :float ],
        :set  => Proc.new { |val| @float_value = val }
      }
    end

    subject { @float_value }

    it "takes a required argument" do
      process %w{ --flt 3.1415 }
      should eq 3.1415
    end

    it "takes a required integer argument" do
      process %w{ --flt 3 }
      should eq 3
    end

    it "rejects a non-float string" do
      args = %w{ --flt foobar }
      expect { process args }.to raise_error(RuntimeError, "invalid argument 'foobar' for option: --flt")
    end

    it "rejects a non-float string as =" do
      args = %w{ --flt=foobar }
      expect { process args }.to raise_error(RuntimeError, "invalid argument 'foobar' for option: --flt")
    end

    it "rejects a non-float number" do
      args = %w{ --flt 1.3.5 }
      expect { process args }.to raise_error(RuntimeError, "invalid argument '1.3.5' for option: --flt")
    end

    it "rejects a non-float number as =" do
      args = %w{ --flt=1.3.5 }
      expect { process args }.to raise_error(RuntimeError, "invalid argument '1.3.5' for option: --flt")
    end
  end
  
  describe "boolean option" do
    def create_option_data optdata
      @boolean_value = nil
      optdata << {
        :tags => %w{ --bool },
        :arg  => [ :boolean ],
        :set  => Proc.new { |val| @boolean_value = val }
      }      
    end

    subject { @boolean_value }
    
    %w{ true yes on }.each do |val|
      it "takes #{val} as true" do
        process [ '--bool', val ]
        should eq true
      end
    end
    
    %w{ false no off }.each do |val|
      it "takes #{val} as false" do
        process [ '--bool', val ]
        should eq false
      end
    end

    it "rejects a non-boolean" do
      args = %w{ --bool oui }
      expect { process args }.to raise_error(RuntimeError, "invalid argument 'oui' for option: --bool")
    end

    it "rejects a non-boolean as =" do
      args = %w{ --bool=oui }
      expect { process args }.to raise_error(RuntimeError, "invalid argument 'oui' for option: --bool")
    end
  end

  describe "option with argument :none" do
    def create_option_data optdata
      @none_value = nil
      optdata << {
        :tags => %w{ --none },
        :arg  => [ :none ],
        :set  => Proc.new { |x| @none_value = 'wasset' }
      }
    end

    subject { @none_value }

    it "can take :none as argument" do
      args = %w{ --none xyz }
      process args
      should eql 'wasset'
      args.should have(1).items
    end
  end

  describe "option without argument type" do
    def create_option_data optdata
      @undefn_value = nil
      optdata << {
        :tags => %w{ --undefn },
        :set  => Proc.new { |x| @undefn_value = 'setitwas' }
      }
    end

    subject { @undefn_value }

    it "defaults to :none" do
      args = %w{ --undefn xyz }
      process args
      should eql 'setitwas'
      args.should have(1).items
    end
  end

  describe "regexp option" do
    describe "with integer type" do
      def create_option_data optdata
        @integer_value = nil
        optdata << {
          :regexp => %r{ ^ - (1\d*) $ }x,
          :arg    => [ :integer ],
          :set    => Proc.new { |val| @integer_value = val },
        }
      end

      subject { @integer_value }

      it "converts value" do
        process %w{ -123 }
        should eq 123
      end
    end

    describe "with string type" do
      def create_option_data optdata
        @string_value = nil
        optdata << {
          :regexp => %r{ ^ - (2\d*) $ }x,
          :arg    => [ :string ],
          :set    => Proc.new { |val| @string_value = val },
        }
      end

      subject { @string_value }

      it "converts value" do
        process %w{ -234 }
        should eq '234'
      end
    end

    describe "with regexp type" do
      def create_option_data optdata
        @regexp_value = nil
        optdata << {
          :regexp => %r{ ^ -- (x[yz]+) $ }x,
          :set    => Proc.new { |val| @regexp_value = val },
        }
      end

      it "does not convert value" do
        process %w{ --xy }
        @regexp_value.should be_kind_of(MatchData)
        @regexp_value[1].should eql 'xy'
      end
    end
  end

  describe "option with required argument, without type" do
    def create_option_data optdata
      @xyz_value = nil
      optdata << {
        :tags => %w{ --xyz },
        :arg  => [ :required ],
        :set  => Proc.new { |v| @xyz_value = v }
      }
    end

    subject { @xyz_value }

    it "takes an argument" do
      process %w{ --xyz abc }
      should eq 'abc'
    end
  end
end
