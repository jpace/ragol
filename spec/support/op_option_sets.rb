require 'ragol/common/option'
require 'ragol/optproc/optset'

module OptProc
  module OptionTestSets
    def create_abc_option_set charlie_options = Hash.new
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
      }.merge(charlie_options)

      optset = OptProc::OptionSet.new optdata
      def optset.name; 'abc'; end
      optset
    end

    def create_fij_option_set
      optdata = Array.new

      @foxtrot = nil
      optdata << {
        :tags => %w{ -f --foxtrot },
        :set  => Proc.new { @foxtrot = true }
      }
      @india = nil
      optdata << {
        :tags => %w{ -i --india },
        :set  => Proc.new { |v| @india = true }
      }
      @juliet = nil
      optdata << {
        :tags => %w{ -j --juliet },
        :arg  => [ :string ],
        :set  => Proc.new { |v| @juliet = v },
        :regexp => Regexp.new('^-(\d+)$')
      }

      optset = OptProc::OptionSet.new optdata
      def optset.name; 'fij'; end
      optset
    end

    def create_ik_option_set
      optdata = Array.new

      @kilo = nil
      optdata << {
        :tags => %w{ -k, --kilo },
        :arg  => [ :string, :optional ],
        :set  => Proc.new { |v| @kilo = v }
      }
      @india = nil
      optdata << {
        :tags => %w{ -i, --india },
        :set  => Proc.new { |v| @india = true }
      }

      optset = OptProc::OptionSet.new optdata
      def optset.name; 'ik'; end
      optset
    end

    def create_dd_option_set
      optdata = Array.new

      @delta = nil
      optdata << {
        :tags => %w{ -d --delta },
        :default => 314,
        :valuetype => :fixnum,
        :process => Proc.new { |v| @delta = v }
      }
      @delay = nil
      optdata << {
        :tags => %w{ -y --delay },
        :valuetype => :string,
        :process => Proc.new { |v| @delay = v }
      }

      optset = OptProc::OptionSet.new optdata
      def optset.name; 'dd'; end
      optset
    end
  end
end
