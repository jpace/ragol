#!/usr/bin/ruby -w
# -*- ruby -*-

shared_examples "defined methods" do |valid_methods, invalid_methods|
  valid_methods.each do |methname|
    it("has method #{methname}") { subject.method(methname).should be_true }
  end

  invalid_methods.each do |methname|
    it("does not have method #{methname}") { expect { subject.method(methname) }.to raise_error(NameError) }
  end
end
