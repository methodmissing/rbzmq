#!/usr/bin/env rake
require 'rake/testtask'
require 'rake/clean'
$:.unshift(File.expand_path('lib'))
ZMQ_ROOT = 'ext/rbzmq'

desc 'Default: test'
task :default => :test

desc 'Run rbzmq tests.'
Rake::TestTask.new(:test) do |t|
  t.libs = [ZMQ_ROOT]
  t.pattern = 'test/test_*.rb'
  t.ruby_opts << '-rtest'
  t.libs << 'test'
  t.warning = true
  t.verbose = true
end
task :test => :build

namespace :build do
  file "#{ZMQ_ROOT}/rbzmq.c"
  file "#{ZMQ_ROOT}/rbzmq.h"
  file "#{ZMQ_ROOT}/extconf.rb"
  file "#{ZMQ_ROOT}/Makefile" => %W(#{ZMQ_ROOT}/rbzmq.c #{ZMQ_ROOT}/rbzmq.h #{ZMQ_ROOT}/extconf.rb) do
    Dir.chdir(ZMQ_ROOT) do
      ruby 'extconf.rb'
    end
  end

  desc "generate makefile"
  task :makefile => %W(#{ZMQ_ROOT}/Makefile #{ZMQ_ROOT}/rbzmq.c)

  dlext = Config::CONFIG['DLEXT']
  file "#{ZMQ_ROOT}/zmq.#{dlext}" => %W(#{ZMQ_ROOT}/Makefile #{ZMQ_ROOT}/rbzmq.c) do
    Dir.chdir(ZMQ_ROOT) do
      sh 'make' # TODO - is there a config for which make somewhere?
    end
  end

  desc "compile rbzmq extension"
  task :compile => "#{ZMQ_ROOT}/zmq.#{dlext}"

  task :clean do
    Dir.chdir(ZMQ_ROOT) do
      sh 'make clean'
    end if File.exists?("#{ZMQ_ROOT}/Makefile")
  end

  CLEAN.include("#{ZMQ_ROOT}/Makefile")
  CLEAN.include("#{ZMQ_ROOT}/zmq.#{dlext}")
end

task :clean => %w(build:clean)

desc "compile"
task :build => %w(build:compile)

task :install do |t|
  Dir.chdir(ZMQ_ROOT) do
    sh 'sudo make install'
  end
end

desc "clean build install"
task :setup => %w(clean build install)