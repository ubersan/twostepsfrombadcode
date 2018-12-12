service postgresql start

sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

service postgresql restart

mix ecto.create

mix phx.server

/bin/zsh