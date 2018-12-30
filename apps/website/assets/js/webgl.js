import "phoenix_html"

import { Elm } from "../src/WebGLPage.elm";

var app = Elm.WebGLPage.init({
  node: document.getElementById("webgl-elm-node")
});
