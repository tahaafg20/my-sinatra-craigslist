class ApplicationController < Sinatra::Base

  register Sinatra::ActiveRecordExtension

  configure do
  	set :views, "app/views"
    set :public_dir, "public"
    #enables sessions as per Sinatra's docs. Session_secret is meant to encript the session id so that users cannot create a fake session_id to hack into your site without logging in. 
    enable :sessions
    set :session_secret, "secret"
  end

  # Renders the home or index page
  get '/' do
    @categories = Category.all
    erb :home, :layout => false
  end

  get '/home' do
    @categories = Category.all
    erb :home, :layout => false
  end
  # Renders the sign up/registration page in app/views/registrations/signup.erb
  get '/registrations/signup' do
    erb :'/registrations/signup', layout: :template
  end

  # Handles the POST request when user submits the Sign Up form. Get user info from the params hash, creates a new user, signs them in, redirects them. 
  post '/registrations' do
   user = User.create(name: params["name"], email: params["email"])
   user.password= params["password"]
   user.save
   session[:user_id]=user.id
   redirect 'users/home'
  end
  
  # Renders the view page in app/views/sessions/login.erb
  get '/sessions/login' do
   erb :'sessions/login', layout: :template
  end

  # Handles the POST request when user submites the Log In form. Similar to above, but without the new user creation.
  post '/sessions' do
    user = User.find_by(email: params["email"])
    if user.password == params["password"]
      session[:user_id] = user.id
      redirect '/users/home'
    else 
      redirect '/sessions/login'
    end
  end

  # Logs the user out by clearing the sessions hash. 
  get '/sessions/logout' do
    session.clear
    redirect '/'
  end

  # Renders the user's individual home/account page. 
  get '/users/home' do
    if (session[:user_id])
      @user = User.find(session[:user_id])
      @categories = Category.all
      erb :'/users/home', :layout => false
    else
      redirect "/sessions/login"
    end
  end

  get '/posts/create_post' do
    @user = User.find(session[:user_id])
    erb :'/posts/create_post', layout: :layout
  end

  post '/posts/create_post' do 
    @user = User.find(session[:user_id])
    newpost = Post.create(user_id: @user.id,subcategory_id: params["subcategory_id"],post_name: params["post_name"],description: params["description"],location: params["location"],payment: params["payment"])
    redirect '/posts/my_posts'
  end

  get '/posts/my_posts' do
    @user = User.find(session[:user_id])
    erb :'/posts/my_posts', layout: :layout
  end

  get '/posts/:id' do
    if session[:user_id]
      @user = User.find(session[:user_id])
      @post = Post.find(params["id"])
      if @user.id == @post.user.id
        @post = Post.find(params["id"])
        erb :'/users/admin', :layout => false
      else
        erb :'/posts/post'
      end
    else
      @post = Post.find(params["id"])
      erb :'/posts/post', layout: :template
    end
  end

  get '/users/:id' do
    @post = Post.find(params["id"])
    erb :'/users/post'
  end
  get '/subcategories/subcategory_posts/:id' do
    if session[:user_id]
      @user = User.find(session[:user_id])
      @sub_posts = Post.where(subcategory_id:(params[:id].to_i))
      @subcategory = Subcategory.find(params[:id].to_i)
      erb :'/users/subcategory_posts', layout: :layout
    else 
      @sub_posts = Post.where(subcategory_id:(params[:id].to_i))
      @subcategory = Subcategory.find(params[:id].to_i)
      erb :'/subcategories/subcategory_posts', layout: :template
    end
    
  end

  get '/users/:id/edit' do
    @user = User.find(session[:user_id])
    @post = Post.find(params["id"])
    erb :'/users/edit'
  end

  put '/users/:id' do
    @user = User.find(session[:user_id])
    @post = Post.find(params["id"])
    @post.update(post_name: params["post_name"], description: params["description"], location: params["location"], payment: params["payment"])
    erb :'/users/:id'
  end

  get '/users/:id/delete_post' do
    @user = User.find(session[:user_id])
    @post = Post.find(params["id"])
    erb :'/users/delete_post'
  end

  delete "/users/:id" do
    @post = Post.find(params["id"])
    @post.destroy
    redirect '/users/home'
  end

end
