require 'rubygems'
require 'rake/testtask'
require 'rubygems/package_task'
require 'fileutils'

Dir['tasks/**/*.rake'].each { |t| load t }

task :default => 'test'

Rake::TestTask.new('test') do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.warning = true
  t.verbose = true
end

spec = Gem::Specification.new do |s| 
  s.name               = "ragol"
  s.version            = "0.0.1"
  s.author             = "Jeff Pace"
  s.email              = "jeugenepace@gmail.com"
  s.homepage           = "http://www.incava.org/projects/ragol"
  s.platform           = Gem::Platform::RUBY
  s.summary            = "Ragol: Another GetOpt Library."
  s.description        = "Another implementation of an option processor."
  s.files              = FileList["lib/**/*"].to_a
  s.require_path       = "lib"
  s.test_files         = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc           = false

  s.add_dependency("riel", ">= 1.1.16")
end
 
Gem::PackageTask.new(spec) do |pkg| 
  pkg.need_zip = true 
  pkg.need_tar_gz = true 
end 
