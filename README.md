## twostepsfrombadcode

- Run `./start_development.sh` to enter dev environment.
- Run `mix deps.get and npm install in apps/website/assets` to get all required dependencies for mix and node to work properly.
- Run `mix phx.server` to compile and run the website exposing port 4000 to the host.

# Production
- Configure elm-webpack-loader with `debug: options.mode === "development"` and `optimize: true` to compile elm for production and remove all debug features.
