require 'sqlite3'

db = SQLite3::Database.new 'barbershop.db'
db.results_as_hash = true

db.execute 'select * from Users' do |row|
  print row['Name']
  print "\t-\t"
  puts row['Datestamp']
  puts '============================================'
end