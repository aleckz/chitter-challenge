require 'sinatra/base'
require 'sinatra/flash'
require './app/models/user'
require './app/models/peep'
require_relative 'data_mapper_setup'

class Chitter < Sinatra::Base
  set :views, proc {File.join(root,'.', 'views')}
  
  enable :sessions
  set :session_secret, 'super secret'

  register Sinatra::Flash

  get '/' do
    redirect '/peeps'    
  end

  get '/peeps' do
    @peeps = Peep.all # (:order => [ :timestamp.desc])
    erb :'peeps/index'
  end

  get '/peeps/new' do
    erb :'peeps/new'
  end

  post '/peeps' do
    Peep.create(title: params[:title], 
                message: params[:message])
    redirect to '/peeps'
  end

  get '/users/new' do
    @user = User.new
    erb :'users/new'
  end

  post '/users' do
    @user = User.new(name: params[:name],
                     username: params[:username],
                     email: params[:email],
                     password: params[:password],
                     password_confirmation: params[:password_confirmation])
    if @user.save
      @user_id = session[:user_id]
      redirect to '/'
    else
      flash.now[:notice] = @user.errors.full_messages
      erb :'/users/new'
    end
  end

  get '/sessions/new' do
    erb :'sessions/new'
  end


  helpers do

    def current_user
     @user ||= User.get(session[:user_id])
    end

  end

end