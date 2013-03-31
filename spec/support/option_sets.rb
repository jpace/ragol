module Synoption
  module OptionTestSets
    def create_abc_option_set tnt_options
      bravo = Synoption::Option.new :bravo, '-x', "blah blah xyz",    nil
      alpha = Synoption::Option.new :alpha, '-a', "abc yadda yadda",  nil
      charlie = Synoption::Option.new :charlie, '-t', "tnt and so forth", nil, charlie_options
      
      optset = Synoption::OptionSet.new bravo, alpha, charlie
      def optset.name; 'testing'; end
      optset
    end

    class EchoOption < Synoption::Option
      def initialize
        super :echo, '-e', "blah blah", nil
      end
    end

    class DeltaOption < Synoption::Option
      def initialize 
        super :delta, '-d', "description of delta",  nil
      end
    end
    
    class FoxtrotOption < Synoption::Option
      def initialize 
        super :foxtrot, '-f', "and so forth", nil
      end
    end
    
    class DefOptionSet < Synoption::OptionSet
      has_option :echo, EchoOption
      has_option :delta, DeltaOption
      has_option :foxtrot, FoxtrotOption

      def name
        'testing'
      end
    end

    def create_def_option_set
      DefOptionSet.new
    end

    # -------------------------------------------------------

    class UghOption < Synoption::Option
      def initialize
        super :ugh, '-u', "you gee ache", nil
      end
    end
    
    class CommonTestOptionSet < Synoption::OptionSet
      has_option :delta, DeltaOption
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
      has_option :echo, EchoOption
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
