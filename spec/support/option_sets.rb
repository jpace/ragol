module Synoption
  module OptionTestSets
    def create_abc_tnt_xyz_option_set tnt_options
      xyz = Synoption::Option.new :xyz, '-x', "blah blah xyz",    nil
      alpha = Synoption::Option.new :alpha, '-a', "abc yadda yadda",  nil
      tnt = Synoption::Option.new :tnt, '-t', "tnt and so forth", nil, tnt_options
      
      optset = Synoption::OptionSet.new [ xyz, alpha, tnt ]
      def optset.name; 'testing'; end
      optset
    end

    class XyzOption < Synoption::Option
      def initialize
        super :xyz, '-x', "blah blah xyz", nil
      end
    end

    class AbcOption < Synoption::Option
      def initialize 
        super :abc, '-a', "abc yadda yadda",  nil
      end
    end
    
    class TntOption < Synoption::Option
      def initialize 
        super :tnt, '-t', "tnt and so forth", nil
      end
    end
    
    class TestOptionSet < Synoption::OptionSet
      has_option :xyz, XyzOption
      has_option :abc, AbcOption
      has_option :tnt, TntOption

      def name
        'testing'
      end
    end

    def create_abc_tnt_xyz_option_set_subclass
      TestOptionSet.new
    end

    # -------------------------------------------------------

    class UghOption < Synoption::Option
      def initialize
        super :ugh, '-u', "you gee ache", nil
      end
    end
    
    class CommonTestOptionSet < Synoption::OptionSet
      has_option :abc, AbcOption
      has_option :ugh, UghOption

      def name
        'common'
      end
    end
    
    def create_common_option_set
      CommonTestOptionSet.new
    end

    # -------------------------------------------------------

    class GhiOption < Synoption::Option
      def initialize
        super :ghi, '-g', "gee ache eye", nil
      end
    end
    
    class AbcTestOptionSet < CommonTestOptionSet
      has_option :xyz, XyzOption
      has_option :ghi, GhiOption

      def name
        'testing'
      end
    end

    def create_abc_test_option_set
      AbcTestOptionSet.new
    end
  end
end
