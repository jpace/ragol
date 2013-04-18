#!/usr/bin/ruby -w
# -*- ruby -*-

module Ragol
  module HashUtil
    def self.copy_hash to_hash, from_hash, fields = Array.new
      fields.each do |fieldnames|
        to_hash[fieldnames.first] = from_hash[fieldnames.find { |x| from_hash[x] }]
      end
    end
  end
end
