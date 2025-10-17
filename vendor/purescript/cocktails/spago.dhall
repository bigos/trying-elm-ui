{ name = "halogen-project"
, dependencies =
  [ "console"
  , "effect"
  , "exceptions"
  , "halogen"
  , "integers"
  , "maybe"
  , "prelude"
  , "transformers"
  , "web-dom"
  , "web-html"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
