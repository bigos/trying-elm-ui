module Main where

import Prelude

import App.Cocktails as Cocktails
import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)

import Data.Maybe (Maybe(..))
import Web.DOM.Element (getAttribute)
import Web.HTML.Window as Window
import Web.HTML.Window (Window)
import Web.HTML.HTMLScriptElement as HTMLScript
import Web.HTML (window)

type TagInsertionConfig =
  { base_url :: Maybe String
  , logname :: Maybe String
  }

readConfig :: Window -> Effect TagInsertionConfig
readConfig win = do
  script <- currentScript =<< Window.document win
  traverse go script
  where
  go script = do
    let elem = HTMLScript.toElement script
    TagInsertionConfig
      <$> getAttribute "data-base_url" elem
      <*> getAttribute "data-logname" elem

main :: Effect Unit
main = HA.runHalogenAff do
  w <- window
  config <- readConfig w
  body <- HA.awaitBody
  runUI Cocktails.component config body
