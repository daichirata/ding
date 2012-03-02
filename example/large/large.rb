require 'sinatra'

class Large < Sinatra::Base
  get '/hi' do
    'Hello World!' * 10000
  end
end

