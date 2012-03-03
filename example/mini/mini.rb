require 'sinatra'

class Mini < Sinatra::Base
  get '/hi' do
    "Hello World!"
  end

  get '/redirect' do
    redirect 'http://localhost:9292/hi'
  end
end

