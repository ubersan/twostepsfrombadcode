// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import { Elm } from "../src/Home.elm";

var app = Elm.Home.init({
  node: document.getElementById("home-elm-node")
});
