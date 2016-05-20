require 'sinatra'
require 'json'
require './key_server'

include KeyServer

keyserver = KeyServerClass.new

Thread.new do
  while true
     keyserver.freeup_keys
     sleep 1
  end
end

get '/' do
  'Welcome to Key Server'
end

post '/keys' do
  # generate set of 10 keys for every call
  # checks to ensure doesn't exceed server
  # key size limit
  content_type :json
  keyserver.create_keys(10)
  {status: "success"}.to_json
end

head '/keys/:id' do
  content_type :json
  k = keyserver.get_key_info(params["id"])
  halt 404 if k == nil
  k.each { |key,val| 
    response.headers["X-#{key}"] = val.to_s
  } 
end

get '/keys' do
  content_type :json
  free_key = keyserver.get_free_key
  if free_key == nil
    halt 404, "No keys available"
  end
  {key: free_key}.to_json
end

delete '/keys/:id' do
  content_type :json
  k = params["id"]
  halt 404 if keyserver.delete_key(k) == false
  {status: "success"}.to_json
end

put '/keys/:id' do
  content_type :json
  k = params["id"]
  halt 404 if keyserver.release_key(k) == false
  {status: "success"}.to_json
end

put '/keepalive/:id' do
  content_type :json
  k = params["id"]
  halt 404 if keyserver.keepalive(k) == false
  {status: "success"}.to_json
end

