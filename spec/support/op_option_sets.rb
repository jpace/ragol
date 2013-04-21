require 'ragol/common/option'
require 'ragol/optproc/optset'

module OptProc
  module OptionTestSets
    def create_abc_option_set
      optdata = Array.new
      @alpha = nil
      optdata << {
        :tags => %w{ -a --alpha },
        :arg  => [ :string ],
        :set  => Proc.new { |v| @alpha = v }
      }
      @bravo = nil
      optdata << {
        :tags => %w{ -b --bravo },
        :arg  => [ :string ],
        :set  => Proc.new { |v| @bravo = v }
      }
      @charlie = false
      optdata << {
        :tags => %w{ -c --charlie },
        :arg  => [ :string ],
        :set  => Proc.new { |v| @charlie = v }
      }
      optset = OptProc::OptionSet.new optdata
      def optset.name; 'abc'; end
      optset
    end
  end
end
