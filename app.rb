require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb :about
end

get '/visit' do
	erb :visit
end

get '/contacts' do
  erb :contacts
end

post '/visit' do
  @user_name = params[:user]
  @phone = params[:phone]
  @datetime = params[:datetime]
  of = File.open 'customers.txt', 'a'
  of.write "Customer: #{@user_name}, Phone: #{@phone}, Date: #{@datetime} \n"
  of.close
  erb 'Спасибо что пользуетесь нашими услугами!'
end