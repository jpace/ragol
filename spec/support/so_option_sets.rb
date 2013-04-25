require 'ragol/synoption/option'
require 'ragol/synoption/fixnum_option'
require 'ragol/synoption/boolean_option'
require 'ragol/synoption/float_option'
require 'ragol/synoption/set'

module Synoption
  module OptionTestSets
    def create_abc_option_set charlie_options = Hash.new
      bravo = Synoption::Option.new :bravo, '-x', "Italian commendations", nil
      alpha = Synoption::Option.new :alpha, '-a', "first Greek letter",  nil
      charlie = Synoption::Option.new :charlie, '-t', "Charles' nickname", nil, charlie_options
      
      optset = Synoption::OptionSet.new bravo, alpha, charlie
      def optset.name; 'abc'; end
      optset
    end

    # -------------------------------------------------------

    class DeltaOption < Synoption::FixnumOption
      def initialize 
        super :delta, '-d', "mouth of a river", 317
      end
    end

    class EchoOption < Synoption::Option
      def initialize
        super :echo, '-e', "description description", "default default"
      end
    end
    
    class XxxFoxtrotOption < Synoption::BooleanOption
      def initialize 
        super :foxtrot, '-f', "a dance"
      end
    end
    
    class FoxtrotOption < Synoption::BooleanOption
      def initialize 
        super(:foxtrot, '-f', "a dance") do |opt|
          opt.name = :foxtrot
          opt.tags = [ '--foxtrot', '-f' ]
          opt.description = "a dance"
        end
      end
    end
    
    class DefOptionSet < Synoption::OptionSet
      has_option :echo, EchoOption
      has_option :delta, DeltaOption
      has_option :foxtrot, FoxtrotOption
    end

    def create_def_option_set
      DefOptionSet.new
    end

    # -------------------------------------------------------

    class GolfOption < Synoption::Option
      def initialize
        super :golf, '-w', "a walk ruined", nil
      end
    end
    
    class HotelOption < Synoption::FloatOption
      def initialize
        super :hotel, '-h', "an upscale motel", 8.79
      end
    end
    
    class DefghOptionSet < DefOptionSet
      has_option :golf, GolfOption
      has_option :hotel, HotelOption
    end

    def create_defgh_option_set
      DefghOptionSet.new
    end
    
    class IndiaOption < Synoption::BooleanOption
      def initialize 
        super :india, '-i', "a country"
      end
    end
    
    class JulietOption < Synoption::Option
      def initialize 
        super :juliet, '-j', "romeo's girlfriend", nil, { :regexp => Regexp.new('^-(\d+)$') }
      end
    end
    
    class FijOptionSet < Synoption::OptionSet
      has_option :foxtrot, FoxtrotOption
      has_option :india, IndiaOption
      has_option :juliet, JulietOption
    end

    def create_fij_option_set
      FijOptionSet.new
    end

    class KiloOption < Synoption::Option
      def initialize 
        super :kilo, '-k', "amount of dust", nil, { :takesvalue => :optional }
      end
    end
    
    class IkOptionSet < Synoption::OptionSet
      has_option :india, IndiaOption
      has_option :kilo, KiloOption
    end

    def create_ik_option_set
      IkOptionSet.new
    end

    class DelayOption < Synoption::Option
      def initialize
        super :delay, '-y', "waiting period", nil
      end
    end

    class DdOptionSet < Synoption::OptionSet
      has_option :delta, DeltaOption
      has_option :delay, DelayOption
    end

    def create_dd_option_set
      DdOptionSet.new
    end

    def process_option args
      optset = Synoption::OptionSet.new
      optset.add create_option
      @results = optset.process args
    end
  end
end
