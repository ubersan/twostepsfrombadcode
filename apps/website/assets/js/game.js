import "phoenix_html"

import { Elm } from "../src/Game.elm";

var app = Elm.Game.init({
  node: document.getElementById("game-elm-node")
});
