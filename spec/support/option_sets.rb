module Synoption
  module OptionTestSets
    def create_abc_tnt_xyz_option_set tnt_options
      xyz = Synoption::Option.new :xyz, '-x', "blah blah xyz",    nil
      abc = Synoption::Option.new :abc, '-a', "abc yadda yadda",  nil
      tnt = Synoption::Option.new :tnt, '-t', "tnt and so forth", nil, tnt_options
      
      @optset = Synoption::OptionSet.new [ xyz, abc, tnt ]
      def @optset.name; 'testing'; end
      @optset
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

      def name; 'testing'; end
    end

    def create_abc_tnt_xyz_option_set_subclass
      @optset = TestOptionSet.new
    end
  end
end
