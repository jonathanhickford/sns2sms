configure do
  db = URI.parse(  ENV['DATABASE_URL'] ? ENV['DATABASE_URL'] : "postgres://user:pass@localhost:5432/dbname")
	
  ActiveRecord::Base.establish_connection(
    :adapter  => 'postgresql',
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  	)
end


