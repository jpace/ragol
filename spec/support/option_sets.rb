module Synoption
  module OptionTestSets
    def create_abc_option_set charlie_options = Hash.new
      bravo = Synoption::Option.new :bravo, '-x', "Italian commendations",    nil
      alpha = Synoption::Option.new :alpha, '-a', "first Greek letter",  nil
      charlie = Synoption::Option.new :charlie, '-t', "Charles' nickname", nil, charlie_options
      
      optset = Synoption::OptionSet.new bravo, alpha, charlie
      def optset.name; 'abc'; end
      optset
    end

    # -------------------------------------------------------

    class EchoOption < Synoption::Option
      def initialize
        super :echo, '-e', "description description", nil
      end
    end

    class DeltaOption < Synoption::Option
      def initialize 
        super :delta, '-d', "mouth of a river",  nil
      end
    end
    
    class FoxtrotOption < Synoption::Option
      def initialize 
        super :foxtrot, '-f', "a dance", nil
      end
    end
    
    class DefOptionSet < Synoption::OptionSet
      has_option :echo, EchoOption
      has_option :delta, DeltaOption
      has_option :foxtrot, FoxtrotOption

      def name
        'def'
      end
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
    
    class HotelOption < Synoption::Option
      def initialize
        super :hotel, '-h', "an upscale motel", nil
      end
    end
    
    class DefghOptionSet < DefOptionSet
      has_option :golf, GolfOption
      has_option :hotel, HotelOption

      def name
        'defgh'
      end
    end

    def create_defgh_option_set
      DefghOptionSet.new
    end
  end
end
