# frozen_string_literal: true

require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] || 'Hello stranger'
  end
end

before '/visit/' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Hello! <a href="https://github.com/bootstrap-ruby/sinatra-bootstrap">Original</a> pattern has been modified for <a href="http://rubyschool.us/">Ruby School</a>'
end

get '/about' do
  erb :about
end

get '/contacts' do
  erb :contacts
end

get '/login_form' do
  erb :login_form
end

get '/logout' do
  session.delete(:identity)
  redirect to '/'
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/visit' do
  # unless session[:identity]
  # session[:previous_url] = request.path
  # @error = 'Sorry, you need to be logged in to visit ' + request.path
  # halt erb(:login_form)
  # end
  erb :visit
end

post '/login/attempt' do
  if params['username'] == 'admin' && params['password'] == 'secret'
    session[:identity] = params['username']
    where_user_came_from = session[:previous_url] || '/'
    redirect to where_user_came_from
  else
    @error = 'Sorry, you enter wrong login or password, try again '
    halt erb(:login_form)
  end
end

post '/visit' do
  @user_name = params[:name]
  @phone = params[:phone]
  @datetime = params[:datetime]
  @barber = params[:barber]
  @color = params[:color]

  hh = {
    name: 'Введите имя',
    phone: 'Введите телефон',
    datetime: 'Выберите дату',
    barber: 'Выберите Парикмахера'
  }

  @error = hh.select { |key, _| params[key] == '' }.values.join(',')

  return erb :visit if @error != ''

  erb "OK, username is #{@username}, #{@phone}, #{@datetime}, #{@barber}, #{@color}"

  Pony.mail(
    to: 'lexx-03@mail.ru',
    via: :smtp,
    via_options: {
      address: 'smtp.gmail.com',
      port: '587',
      enable_starttls_auto: true,
      user_name: 'alexxxicus@gmail.com',
      password: 'baqtpdgclrcuxvly',
      authentication: :plain, # :plain, :login, :cram_md5, no auth by default
      domain: 'gmail.com' # the HELO domain provided by the client to the server
    },
    subject: 'Новый клиент',
    body: "Username is #{@username}, #{@phone}, #{@datetime}, #{@barber}, #{@color}"
  )
  erb "OK, username is #{@username}, #{@phone}, #{@datetime}, #{@barber}, #{@color}"
end

post '/about' do
  @feedback = params[:feedback]
  of = File.open 'feebacks.txt', 'a'
  of.write "#{@feedback} \n"
  of.close
  erb 'Спасибо за ваш отзыв!'
end
