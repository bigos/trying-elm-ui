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
  , "psci-support"
  , "strings"
  , "transformers"
  , "tuples"
  , "web-dom"
  , "web-html"
  , "web-uievents"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
