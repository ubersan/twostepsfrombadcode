import "phoenix_html"

import { Elm } from "../src/WebGL.elm";

var app = Elm.WebGL.init({
  node: document.getElementById("webgl-elm-node")
});
