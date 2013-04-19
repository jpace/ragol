#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/log'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

Logue::Log.level = Logue::Log::INFO
Logue::Log.set_widths(-35, 4, -35)
