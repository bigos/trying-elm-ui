{ name = "counter"
, dependencies =
  [ "affjax"
  , "affjax-web"
  , "argonaut"
  , "argonaut-codecs"
  , "argonaut-core"
  , "arrays"
  , "console"
  , "effect"
  , "either"
  , "exceptions"
  , "flame"
  , "integers"
  , "lists"
  , "maybe"
  , "prelude"
  , "strings"
  , "stringutils"
  , "web-dom"
  , "web-html"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
