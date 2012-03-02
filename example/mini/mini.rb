require 'sinatra'

class Mini < Sinatra::Base
  get '/hi' do
    "Hello World!"
  end
end

