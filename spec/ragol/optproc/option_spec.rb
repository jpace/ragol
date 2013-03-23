#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optproc'

Logue::Log.level = Logue::Log::INFO

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

  subject { @value }

  before do
    optdata = Array.new
    create_option_data optdata
    create_set optdata
  end
  
  describe "option with argument :none" do
    def create_option_data optdata
      @value = nil
      optdata << {
        :tags => %w{ --none },
        :arg  => [ :none ],
        :set  => Proc.new { |x| @value = 'wasset' }
      }
    end

    it "can take :none as argument" do
      args = %w{ --none xyz }
      process args
      should eql 'wasset'
      args.should have(1).items
    end
  end

  describe "option without argument type" do
    def create_option_data optdata
      @value = nil
      optdata << {
        :tags => %w{ --undefn },
        :set  => Proc.new { |x| @value = 'setitwas' }
      }
    end

    it "defaults to :none" do
      args = %w{ --undefn xyz }
      process args
      should eql 'setitwas'
      args.should have(1).items
    end
  end

  describe "option with required argument, without type" do
    def create_option_data optdata
      @value = nil
      optdata << {
        :tags => %w{ --xyz },
        :arg  => [ :required ],
        :set  => Proc.new { |v| @value = v }
      }
    end

    it "takes an argument" do
      process %w{ --xyz abc }
      should eq 'abc'
    end
  end

  describe "option with both tags and regexps" do
    def create_option_data optdata
      @value = nil
      optdata << {
        :tags => %w{ -C --context },
        :res  => %r{ ^ - ([1-9]\d*) $ }x,
        :arg  => [ :optional, :integer ],
        :set  => Proc.new { |val, opt, args| @value = val || 2 },
        :rc   => %w{ context },
      }
    end

    it "takes a tag argument" do
      process %w{ --context 17 }
      should eq 17
    end

    it "ignore missing tag argument" do
      process %w{ --context }
      should eq 2
    end

    it "takes the regexp value (not argument)" do
      process %w{ -17 }
      should eq 17
    end
  end
end
