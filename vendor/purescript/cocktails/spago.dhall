{ name = "halogen-project"
, dependencies =
  [ "aff"
  , "affjax"
  , "affjax-web"
  , "argonaut"
  , "argonaut-codecs"
  , "arrays"
  , "console"
  , "debug"
  , "effect"
  , "either"
  , "exceptions"
  , "halogen"
  , "integers"
  , "lists"
  , "maybe"
  , "prelude"
  , "strings"
  , "transformers"
  , "web-dom"
  , "web-html"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
