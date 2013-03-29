module Synoption
  module OptionTestSets
    def create_abc_tnt_xyz tnt_options
      @xyz = Synoption::Option.new :xyz, '-x', "blah blah xyz",    nil
      @abc = Synoption::Option.new :abc, '-a', "abc yadda yadda",  nil
      @tnt = Synoption::Option.new :tnt, '-t', "tnt and so forth", nil, tnt_options
      
      @optset = Synoption::OptionSet.new [ @xyz, @abc, @tnt ]
      def @optset.name; 'testing'; end
      @optset
    end
  end
end
