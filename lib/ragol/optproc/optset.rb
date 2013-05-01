#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optset'

module OptProc
  class OptionSet < Ragol::OptionSet
    include Logue::Loggable
    
    def initialize data
      super :data => data
    end

    # this is a legacy method; process should be used instead.
    def process_option argslist
      set_option argslist
    end
  end
end
