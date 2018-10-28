run:
	bundle exec rerun -b app/app.rb

test:
	bundle exec rspec spec

init:
	bundle exec ruby app/init_db.rb
