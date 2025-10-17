{ name = "halogen-project"
, dependencies =
  [ "affjax-web"
  , "argonaut"
  , "console"
  , "effect"
  , "exceptions"
  , "halogen"
  , "integers"
  , "maybe"
  , "prelude"
  , "strings"
  , "stringutils"
  , "transformers"
  , "web-dom"
  , "web-html"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
