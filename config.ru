require 'rubygems'
require 'bundler'

Bundler.require
require './app_server'
run Sinatra::Application
