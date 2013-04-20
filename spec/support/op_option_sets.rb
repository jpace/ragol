require 'ragol/common/option'
require 'ragol/optproc/optset'

module OptProc
  module OptionTestSets
    def create_abc_option_set
      optdata = Array.new
      @alpha = false
      optdata << {
        :tags => %w{ -a --alpha },
        :set  => Proc.new { @alpha = true }
      }
      @bravo = false
      optdata << {
        :tags => %w{ -b --bravo },
        :set  => Proc.new { @bravo = true }
      }
      @charlie = false
      optdata << {
        :tags => %w{ -c --charlie },
        :set  => Proc.new { @charlie = true }
      }
      optset = OptProc::OptionSet.new optdata
      def optset.name; 'abc'; end
      optset
    end
  end
end
