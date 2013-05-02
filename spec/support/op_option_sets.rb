require 'ragol/option'
require 'ragol/optproc/optset'
require 'support/optset_data'

module OptProc
  module OptionTestSets
    include OptionTestData
    
    def create_abc_option_set charlie_options = Hash.new
      optset = OptProc::OptionSet.new create_abc_option_data(charlie_options)
      def optset.name; 'abc'; end
      optset
    end

    def create_fij_option_set
      optset = OptProc::OptionSet.new create_fij_option_data
      def optset.name; 'fij'; end
      optset
    end

    def create_ik_option_set
      optset = OptProc::OptionSet.new create_ik_option_data
      def optset.name; 'ik'; end
      optset
    end

    def create_dd_option_set
      optset = OptProc::OptionSet.new create_dd_option_data
      def optset.name; 'dd'; end
      optset
    end
  end
end
