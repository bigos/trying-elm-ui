{ name = "counter"
, dependencies =
  [ "affjax"
  , "affjax-web"
  , "argonaut"
  , "console"
  , "effect"
  , "either"
  , "exceptions"
  , "flame"
  , "integers"
  , "lists"
  , "maybe"
  , "prelude"
  , "web-dom"
  , "web-html"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
