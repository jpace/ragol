#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/common/matchers'

module Synoption
  class Matchers < Ragol::Matchers
    def initialize tag, name, negate, regexp
      long_tag = '--' + name.to_s.gsub('_', '-')
      super [ tag, long_tag ], negate, regexp && [ regexp ]
    end
  end
end
