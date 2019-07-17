# frozen_string_literal: true

require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'

def get_db
  db = SQLite3::Database.new 'barbershop.db'
  db.results_as_hash = true
  return db
end
#Проверка на наличие парикмахера
def is_barber_exists? db,name
  db.execute('select * from Barbers where Barbers=?', [name]).size > 0
end
#Наполнение таблицы при условии отсутствия такого парикмахера
def seed_db db, barbers
  barbers.each do |barber|
    if !is_barber_exists? db,barber
      db.execute 'insert into Barbers (Barbers) values (?)',[barber]
    end
  end
end

configure do
  enable :sessions
  db = SQLite3::Database.new 'barbershop.db'
  db.execute 'CREATE TABLE IF NOT EXISTS
    "Users"
    (
      "Id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "Name" VARCHAR,
      "Phone" VARCHAR,
      "Datestamp" VARCHAR,
      "Barber" VARCHAR,
      "Color" VARCHAR
    )'
  db.execute 'CREATE TABLE IF NOT EXISTS
    "Barbers"
    (
      "Id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "Barbers" VARCHAR
    )'
  seed_db db,['Никодим', 'Афанасий', 'Ярополк', 'Святозар', 'Епифан', 'Махмуд']
end

helpers do
  def username
    session[:identity] || 'Hello stranger'
  end
end

before do
  #unless session[:identity]
  #  session[:previous_url] = request.path
  #  @error = 'Sorry, you need to be logged in to visit ' + request.path
  #  halt erb(:login_form)

  db = get_db
  @barbers = db.execute 'select * from Barbers'

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
    body: "Username is #{@user_name}, #{@phone}, #{@datetime}, #{@barber}, #{@color}"
  )
  db = get_db
  db.execute 'INSERT INTO
    Users
    (
       Name,
       Phone,
       Datestamp,
       Barber,
       Color
    )
    VALUES
    (?, ?, ?, ?, ?)', [@user_name, @phone, @datetime, @barber, @color]
  db.close
  erb "<h2> Спасибо что пользуетесь нашими услугами! </h2>"
end

post '/about' do
  @email = params[:email]
  @feedback = params[:feedback]
  db = SQLite3::Database.new 'test.sqlite'
  db.execute "INSERT INTO Contacts (Email, Message)
  VALUES ('#{@email}', '#{@feedback}')"
  db.close
  erb 'Спасибо за ваш отзыв!'
end

get '/showusers' do
  db = get_db
  @result = db.execute 'select * from Users order by Id desc'
  db.close
  erb :showusers
end

