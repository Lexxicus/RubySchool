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
  @user_name = params[:username]
  @phone = params[:phone]
  @datetime = params[:datetime]
  @barber = params[:barber]
  of = File.open 'customers.txt', 'a'
  of.write "Customer: #{@user_name}, Phone: #{@phone}, Date: #{@datetime}, Master: #{@barber} \n"
  of.close
  erb 'Спасибо что пользуетесь нашими услугами!'
end

post '/about' do
  @feedback = params[:feedback]
  of = File.open 'feebacks.txt', 'a'
  of.write "#{@feedback} \n"
  of.close
  erb 'Спасибо за ваш отзыв!'
end