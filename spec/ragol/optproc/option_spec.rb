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

  describe "string option" do
    describe "required (implicit)" do
      before :each do
        optdata = Array.new

        @string_value = nil
        optdata << {
          :tags => %w{ --str },
          :arg  => [ :string ],
          :set  => Proc.new { |v| @string_value = v }
        }

        create_set optdata
      end

      it "takes a required argument" do
        process %w{ --str xyz }
        @string_value.should eq 'xyz'
      end

      it "takes a required argument with =" do
        process %w{ --str=xyz }
        @string_value.should eq 'xyz'
      end

      it "takes a required argument matching tag" do
        process %w{ --str -foo }
        @string_value.should eq '-foo'
      end

      it "expects a required argument" do
        args = %w{ --str }
        expect { process args }.to raise_error(RuntimeError, "value expected for option: --str")
      end

    end

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

      create_set optdata
    end

    it "takes a required argument" do
      process %w{ --str xyz }
      @string_value.should eq 'xyz'
    end

    it "takes a required argument with =" do
      process %w{ --str=xyz }
      @string_value.should eq 'xyz'
    end

    it "takes a required argument matching tag" do
      process %w{ --str -foo }
      @string_value.should eq '-foo'
    end

    it "expects a required argument" do
      args = %w{ --str }
      expect { process args }.to raise_error(RuntimeError, "value expected for option: --str")
    end

    it "takes an optional argument" do
      process %w{ --sopt xyz }
      @sopt_value.should eq 'xyz'
    end

    it "takes an optional argument with =" do
      process %w{ --sopt=xyz }
      @sopt_value.should eq 'xyz'
    end

    it "ignores a missing optional argument" do
      process %w{ --sopt }
      @sopt_value.should be_nil
    end

    it "optional ignores a following --xyz option" do
      process %w{ --sopt --xyz }
      @sopt_value.should be_nil
    end

    it "optional ignores a following -x option" do
      process %w{ --sopt -x }
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
      
      create_set optdata
    end

    it "takes a required argument" do
      process %w{ --int 1 }
      @integer_value.should eq 1
    end

    it "rejects a non-integer" do
      args = %w{ --int 1.0 }
      expect { process args }.to raise_error(RuntimeError, "invalid argument '1.0' for option: --int")
      @integer_value.should be_nil
    end

    it "rejects a non-integer as =" do
      args = %w{ --int=1.0 }
      expect { process args }.to raise_error(RuntimeError, "invalid argument '1.0' for option: --int")
      @integer_value.should be_nil
    end

    it "takes an optional argument" do
      process %w{ --iopt 1 }
      @iopt_value.should eq 1
    end

    it "takes an optional argument as =" do
      process %w{ --iopt=1 }
      @iopt_value.should eq 1
    end

    it "ignores a missing optional argument" do
      process %w{ --iopt }
      @iopt_value.should be_nil
    end

    it "optional argument rejects a non-integer" do
      args = %w{ --iopt 1.0 }
      expect { process args }.to raise_error(RuntimeError, "invalid argument '1.0' for option: --iopt")
      @iopt_value.should be_nil
    end

    it "optional argument rejects a non-integer as =" do
      args = %w{ --iopt=1.0 }
      expect { process args }.to raise_error(RuntimeError, "invalid argument '1.0' for option: --iopt")
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
      
      create_set optdata
    end

    it "takes a required argument" do
      process %w{ --flt 3.1415 }
      @float_value.should eq 3.1415
    end

    it "takes a required integer argument" do
      process %w{ --flt 3 }
      @float_value.should eq 3
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
    before :each do
      optdata = Array.new

      @boolean_value = nil
      optdata << {
        :tags => %w{ --bool },
        :arg  => [ :boolean ],
        :set  => Proc.new { |val| @boolean_value = val }
      }
      
      create_set optdata
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
    before :each do
      optdata = Array.new

      @none_value = nil
      optdata << {
        :tags => %w{ --none },
        :arg  => [ :none ],
        :set  => Proc.new { |x| @none_value = 'wasset' }
      }

      @undefn_value = nil
      optdata << {
        :tags => %w{ --undefn },
        :set  => Proc.new { |x| @undefn_value = 'setitwas' }
      }

      create_set optdata
    end

    it "can take :none as argument" do
      args = %w{ --none xyz }
      process args
      @none_value.should eql 'wasset'
      args.should have(1).items
    end

    it "defaults to :none" do
      args = %w{ --undefn xyz }
      process args
      @undefn_value.should eql 'setitwas'
      args.should have(1).items
    end
  end

  describe "option with argument :required" do
    before :each do
      optdata = Array.new

      @str_value = nil
      optdata << {
        :tags => %w{ --str },
        :arg  => [ :string, :required ],
        :set  => Proc.new { |x| @str_value = x }
      }

      create_set optdata
    end

    it "takes the argument" do
      args = %w{ --str foo }
      process args
      @str_value.should eql 'foo'
      args.should have(0).items
    end

    it "expects a required argument" do
      args = %w{ --str }
      expect { process args }.to raise_error(RuntimeError, "value expected for option: --str")
    end
  end

  describe "regexp option" do
    before :each do
      optdata = Array.new

      @integer_value = nil
      optdata << {
        :regexp => %r{ ^ - (1\d*) $ }x,
        :arg    => [ :integer ],
        :set    => Proc.new { |val| @integer_value = val },
      }

      @string_value = nil
      optdata << {
        :regexp => %r{ ^ - (2\d*) $ }x,
        :arg    => [ :string ],
        :set    => Proc.new { |val| @string_value = val },
      }

      @regexp_value = nil
      optdata << {
        :regexp => %r{ ^ -- (x[yz]+) $ }x,
        :set    => Proc.new { |val| @regexp_value = val },
      }
      
      create_set optdata
    end

    it "converts integer" do
      process %w{ -123 }
      @integer_value.should eq 123
    end

    it "converts string" do
      process %w{ -234 }
      @string_value.should eq '234'
    end

    it "does not convert regexp" do
      process %w{ --xy }
      @regexp_value.should be_kind_of(MatchData)
      @regexp_value[1].should eql 'xy'
    end
  end

  describe "option without arg type" do
    before :each do
      optdata = Array.new

      @xyz_value = nil
      optdata << {
        :tags => %w{ --xyz },
        :arg  => [ :required ],
        :set  => Proc.new { |v| @xyz_value = v }
      }
      
      create_set optdata
    end

    it "takes a required argument" do
      process %w{ --xyz abc }
      @xyz_value.should eq 'abc'
    end
  end
end
