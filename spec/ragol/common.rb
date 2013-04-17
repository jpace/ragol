#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/log'

Logue::Log.level = Logue::Log::INFO

# ignore what they have in ENV[HOME]    
ENV['HOME'] = '/this/should/not/exist'
