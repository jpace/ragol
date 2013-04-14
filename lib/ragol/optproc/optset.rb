#!/usr/bin/ruby -w
# -*- ruby -*-

require 'ragol/optproc/option'
require 'ragol/common/option_set'

module OptProc
  class OptionSet < Ragol::OptionSet
    include Logue::Loggable
    
    attr_reader :options
    
    def initialize data
      options = data.collect do |optdata|
        OptProc::Option.new optdata
      end
      super(*options)
    end

    def name
      'testing'
    end

    # this is a legacy method; process should be used instead.
    def process_option argslist
      set_option argslist
    end
  end
end
