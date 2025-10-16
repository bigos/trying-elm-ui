module Main where

import Prelude

import App.Cocktails as Cocktails
import Control.Monad.Error.Class (throwError)
import Data.Maybe (Maybe(..), maybe)
import Effect (Effect)
import Effect.Exception (error, throw)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Web.DOM.Element (getAttribute)
import Web.DOM.NonElementParentNode (getElementById)
import Web.DOM.ParentNode (QuerySelector(..))
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

{-
========== configuration =================================
* elementName
name of the tag or the ID for the output, it can use "body" for pull page app
here we use #halogen because we place output in a div with id halogen
* configTagid
ID of the tag with data attributes used for configuration
* buildConfig
function that reads from the data
-}

main :: Effect Unit
main = HA.runHalogenAff do
  let elementName = "#halogen-cocktail"
  let configTagId = "halogen-cocktail-flags"
  w <- window
  doc <- document w
  container <- getElementById configTagId $ toNonElementParentNode doc
  case container of
    Nothing ->
      throw "container element not found"
    Just el ->
      do
        config <- buildConfig el
        HA.runHalogenAff do
          _ <- HA.awaitBody
          element <- awaitElement
          runUI Cocktails.component config element
      where
      awaitElement = do
        element <- HA.selectElement (QuerySelector elementName)
        maybe (throwError (error ("could not find the expected element " <> elementName))) pure element
      -- function that reads the data from the config tag attributes
      buildConfig element =
        ( { base_url: _, logname: _ }
            <$> getAttribute "data-base_url" element
            <*> getAttribute "data-logname" element
        )
