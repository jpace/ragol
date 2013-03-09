#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/optproc'

describe OptProc::Option do
  before :all do
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end
  
  describe :match_tag do
    before :all do
      @opt = OptProc::Option.new :tags => %w{ --after-context -A }, :arg => [ :integer ]
    end

    def run_match tag
      @opt.match [ tag ]
    end

    describe "exact match" do
      it "long tag" do
        run_match('--after-context').should == 1.0
      end

      it "long tag with =" do
        run_match('--after-context=3').should == 1.0
      end

      it "short tag" do
        run_match('-A').should == 1.0
      end
    end
    
    describe "non match" do
      it "wrong long tag" do
        run_match('--before-context').should be_nil
      end

      it "wrong short tag" do
        run_match('-b').should be_nil
      end
    end
    
    describe "is case sensitive" do
      it "long tag" do
        run_match('--After-Context').should be_nil
      end

      it "short tag" do
        run_match('-a').should be_nil
      end
    end

    describe "partial match" do
      it "long tag" do
        run_match('--after-cont').should == 0.12
      end

      it "long tag with =" do
        run_match('--after-cont=3').should == 0.12
      end
    end
  end
end

__END__

class OptionTestCase < Test::Unit::TestCase
  def setup
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end

  def run_match_value_test opt, exp, val
    m = opt.match_value val
    assert !!m == !!exp, "match value #{val}; expected: #{exp.inspect}; actual: #{m.inspect}"
  end

  def test_value_none
    opt = OptProc::Option.new(:arg => [ :none ])

    {
      '34'    => nil,
      '34.12' => nil
    }.each do |val, exp|
      run_match_value_test opt, exp, val
    end
  end

  def test_value_integer
    opt = OptProc::Option.new(:arg => [ :integer ])

    {
      '34'    => true,
      '34.12' => nil,
      '-34'   => true,
      '+34'   => true,
    }.each do |val, exp|
      run_match_value_test opt, exp, val
    end
  end

  def test_value_float
    opt = OptProc::Option.new(:arg  => [ :float ])

    {
      '34'    => true,
      '34.12' => true,
      '.12'   => true,
      '.'     => false,
      '12.'   => false,
    }.each do |val, exp|
      run_match_value_test opt, exp, val
    end
  end

  def test_value_string
    opt = OptProc::Option.new(:arg  => [ :string ])

    {
      '34'    => true,
      '34.12' => true,
      '.12'   => true,
      '.'     => true,
      '12.'   => true,
      'hello' => true,
      'a b c' => true,
      ''      => true,
    }.each do |val, exp|
      [ 
        '"' + val + '"',
        "'" + val + "'",
        val,
      ].each do |qval|
        run_match_value_test opt, exp, qval
      end
    end
  end

  def test_after_context_float
    after = nil
    opt = OptProc::Option.new(:tags => %w{ --after-context -A },
                              :arg  => [ :required, :float ],
                              :set  => Proc.new { |val| after = val })
    [ 
      %w{ --after-context 3 },
      %w{ --after-context=3 },
      %w{ -A              3 },
    ].each do |args|
      after = nil

      m = opt.match args
      assert_equal 1.0, m, "args: #{args.inspect}"
      opt.set_value args
      assert_equal 3.0, after
    end
  end

  def test_regexp_option
    ctx = nil
    opt = OptProc::Option.new(:res  => %r{ ^ - ([1-9]\d*) $ }x,
                              :tags => %w{ --context -C },
                              :arg  => [ :optional, :integer ],
                              :set  => Proc.new { |val| ctx = val })
    [ 
      %w{ --context 3 },
      %w{ --context=3 },
      %w{ -C        3 },
    ].each do |args|
      ctx = nil

      m = opt.match args
      assert_equal 1.0, m, "args: #{args.inspect}"
      opt.set_value args
      assert_equal 3, ctx
    end
    
    vals = (1 .. 10).to_a  | (1 .. 16).collect { |x| 2 ** x }
    vals.each do |val|
      args = [ '-' + val.to_s, 'foo' ]

      ctx = nil

      m = opt.match args
      assert_equal 1.0, m, "args: #{args.inspect}"
      opt.set_value args
      assert_equal val, ctx
    end
  end

  def test_value_regexp
    range_start = nil
    opt = OptProc::Option.new(:tags => %w{ --after },
                              :arg  => [ :required, :regexp, %r{ ^ (\d+%?) $ }x ],
                              :set  => Proc.new { |md| range_start = md[1] })
    
    %w{ 5 5% 10 90% }.each do |rg|
      [
        [ '--after',   rg ],
        [ '--after=' + rg ]
      ].each do |args|
        range_start = nil
        
        m = opt.match args
        assert_equal 1.0, m, "args: #{args.inspect}"
        opt.set_value args
        assert_equal rg, range_start
      end
    end
  end

  def test_match_rc
  end
end
