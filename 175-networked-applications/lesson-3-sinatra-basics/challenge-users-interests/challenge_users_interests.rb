require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'

before do
  @users = YAML.load_file('users.yaml')
end

helpers do
  def count_interests(content)
    content.sum { |_, user_data| user_data[:interests].size }
  end
end

get "/" do
  redirect "/users"
end

get "/users" do
  erb :users
end

get "/users/:user" do
  @user = params[:user]

  not_found unless @users.keys.map(&:to_s).include?(@user.downcase)

  @email = @users[@user.to_sym][:email]
  @interests = @users[@user.to_sym][:interests]

  erb :user
end

not_found do
  redirect "/"
end
