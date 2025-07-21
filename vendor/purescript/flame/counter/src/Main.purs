-- | Counter example using side effects free updating
module Main where

import Data.Argonaut.Decode.Class
import Data.Argonaut.Encode.Class
import Data.List
import Prelude

import Affjax.ResponseFormat as AR
import Affjax.Web as A
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode.Error (JsonDecodeError)
import Data.Either (Either(..))
import Data.Int (fromString)
import Data.Maybe (Maybe(..), fromMaybe)
import Effect (Effect)
import Effect.Exception (throw)
import Flame (QuerySelector(..))
import Flame.Application.Effectful (AffUpdate)
import Flame.Application.Effectful as FAE
import Flame.Html.Attribute as HA
import Flame.Html.Element as HE
import Flame.Types (Html, NodeData, (:>))
import Web.DOM.Element (getAttribute)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

-- *TYPES --

type Model =
  { url ∷ String
  , result ∷ Result
  , counter :: Int
  , flags :: Flags
  , dirs :: Dirs
  , resultFiles :: ResultFiles
  }

type Flags =
  { counter_start :: Maybe String
  , base_url :: Maybe String
  , logname :: Maybe String
  , home :: Maybe String
  , show_hidden :: Maybe String
  }

type Files = { pwd :: String, showHidden :: Boolean, files :: List String }

type Dirs = { leftDir :: Maybe Files, rightDir :: Maybe Files }

type FetchingFilePost = { pwd :: String, show_hidden :: Boolean }

data Message = UpdateUrl String | Fetch | Increment | Decrement | Initialize Flags | FetchFiles

data Result = NotFetched | Fetching | Ok String | Error String
data ResultFiles = NotFetchedFile | FetchingFile | OkFile String | ErrorFile String

derive instance eqResult ∷ Eq Result

-- *INIT --

init ∷ Model
init =
  { url: "https://httpbin.org/get"
  , result: NotFetched
  , counter: 0
  , flags:
      { counter_start: Nothing
      , base_url: Nothing
      , logname: Nothing
      , home: Nothing
      , show_hidden: Nothing
      }
  , dirs: { leftDir: Nothing, rightDir: Nothing }
  , resultFiles: NotFetchedFile
  }

-- *UPDATE --

fetchingFilePostToJson :: FetchingFilePost -> Json
fetchingFilePostToJson = encodeJson

jsonToFiles :: Json -> Either JsonDecodeError Files
jsonToFiles = decodeJson

update ∷ AffUpdate Model Message
update { display, model, message } =
  case message of
    Initialize flags -> FAE.diff
      { url: model.url
      , result: model.result
      , counter: flagsCounter flags
      , flags: flags
      }
    UpdateUrl url → FAE.diff
      { url, result: NotFetched }
    Fetch → do
      display $ FAE.diff' { result: Fetching }
      response ← A.get AR.string model.url
      FAE.diff <<< { result: _ } $ case response of
        Left error → Error $ A.printError error
        Right payload → Ok payload.body
    FetchFiles -> do
      display $ FAE.diff' { resulFiles: FetchingFile }
      -- https://github.com/JordanMartinez/purescript-cookbook/blob/d6256a70d609fabeb3674dad62fb4d436895b1c6/recipes/AffjaxPostNode/src/Main.purs#L46
      response <-
        ( A.post AR.json ((fromMaybe "" model.flags.base_url) <> "/api/list-files")
            ( Just
                ( AR.json
                    ( fetchingFilePostToJson
                        ( -- FetchingFilePost "/home/jacek/" false
                          { pwd: "/home/jacek/"
                          , show_hidden: false
                          }
                        )
                    )
                )
            )

        )
      FAE.diff <<< { resultFiles: _ } $ case response of
        Left error -> Error $ A.printError error
        Right payload -> OkFile payload.body
    Increment -> FAE.diff
      { url: model.url, result: model.result, counter: model.counter + 1 }
    Decrement -> FAE.diff
      { url: model.url, result: model.result, counter: model.counter - 1 }

flagsCounter :: Flags -> Int
flagsCounter flags =
  fromMaybe (-5) (fromString (fromMaybe "" flags.counter_start))

-- *VIEW --
bgColor :: Int -> String
bgColor counter = if counter < 0 then "red" else "lime"

view ∷ Model → Html Message
view { url, result, counter, flags } = HE.main "main"
  [ HE.button [ HA.onClick Decrement ] "-"
  , HE.span
      [ HA.styleAttr
          ( "background-color: "
              <> (bgColor counter)
              <> "; "
              <> "margin: auto 1em;"
          )
      ]
      [ HE.text (show counter) ]
  , HE.button [ HA.onClick Increment ] "+"
  , HE.br
  , HE.input [ HA.onInput UpdateUrl, HA.value url, HA.type' "text" ]
  , HE.button [ HA.onClick Fetch, HA.disabled $ result == Fetching ] "Fetch"
  , case result of
      NotFetched →
        HE.div_ "Not Fetched..."
      Fetching →
        HE.div_ "Fetching..."
      Ok ok →
        HE.pre_ <<< HE.code_ $ "Ok: " <> ok
      Error error →
        HE.div_ $ "Error: " <> error
  , HE.div (da_border_red)
      [ HE.div (da_border_green) "general toolbar"
      , HE.div [ HA.styleAttr "display: inline-flex" ]
          [ HE.div da_border_red (panel "left")
          , HE.div da_border_green (panel "right")
          ]
      ]
  , HE.h3_ "flags"
  , HE.p_ (show flags)
  ]

names :: Array String
names = [ "Ala", "ma", "kota" ]

panel :: forall h. String -> Array (Html h)
panel side =
  [ HE.div da_border_blue (side <> " toolbar")
  , HE.div_ "boo"
  ] <> (map (\n -> HE.div_ n) names) <>
    [ HE.div
        ( [ HA.styleAttr "background: yellow" ]

        )
        (side <> " status")
    ]

da_border_red :: forall t. Array (NodeData t)
da_border_red = [ HA.styleAttr ("border: solid red 1px") ]

da_border_green :: forall t. Array (NodeData t)
da_border_green = [ HA.styleAttr ("border: solid green 1px") ]

da_border_blue :: forall t. Array (NodeData t)
da_border_blue = [ HA.styleAttr ("border: solid blue 1px") ]

-- *MAIN --
main ∷ Effect Unit
main = do
  let outputTag = "#flame"
  let configTagId = "flame_flags"
  w <- window
  doc <- document w
  container <- getElementById configTagId $ toNonElementParentNode doc
  case container of
    Nothing ->
      throw "container element not found"
    Just element ->
      do
        flags <- buildFlags
        FAE.mount_
          (QuerySelector outputTag)
          { init: init :> (Just (Initialize flags))
          , subscribe: []
          , update
          , view
          }
      where
      buildFlags :: Effect Flags
      buildFlags =
        ( { counter_start: _, base_url: _, logname: _, home: _, show_hidden: _ }
            <$> getAttribute "data-counter-start" element
            <*> getAttribute "data-base-url" element
            <*> getAttribute "data-logname" element
            <*> getAttribute "data-home" element
            <*> getAttribute "data-show-hidden" element
        )
