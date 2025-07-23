-- | Counter example using side effects free updating
module Main where

--import Prelude
import Prelude (class Eq, class Show, Unit, bind, discard, map, negate, show, ($), (+), (-), (<), (<$>), (<*>), (<<<), (<>), (==))

import Affjax.RequestBody (json)
import Affjax.ResponseFormat as AR
import Affjax.Web as A
import Data.Argonaut (encodeJson, decodeJson)
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode.Error (JsonDecodeError)
import Data.Either (Either(..))
import Data.Int (fromString)
import Data.List (List)
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

type Files =
  { pwd :: String
  , show_hidden :: Boolean
  , files :: List String
  }

type Dirs = { leftDir :: Maybe Files, rightDir :: Maybe Files }

type FetchingFilePost =
  { pwd :: String
  , show_hidden :: Boolean
  }

data Message = UpdateUrl String | Fetch | Increment | Decrement | Initialize Flags | FetchFiles

data Result = NotFetched | Fetching | Ok String | Error String
data ResultFiles = NotFetchedFile | FetchingFile | OkFile Files | ErrorFile String

derive instance eqResult ∷ Eq Result

derive instance eqResultFiles ∷ Eq ResultFiles

instance showResult :: Show (Result) where
  show :: Result -> String
  show (NotFetched) = "NotFetched"
  show (Fetching) = "Fetching"
  show (Ok a) = "Ok " <> show a
  show (Error a) = "Error " <> show a

instance showResultFiles :: Show (ResultFiles) where
  show :: ResultFiles -> String
  show (NotFetchedFile) = "NotFetchedFile"
  show (FetchingFile) = "FetchingFile"
  show (OkFile a) = "OkFile " <> show a
  show (ErrorFile a) = "ErrorFile " <> show a

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
      display $ FAE.diff'
        { resultFiles: FetchingFile }
      response <-
        ( A.post AR.json ((fromMaybe "" model.flags.base_url) <> "/api/list-files")
            (Just $ json $ fetchingFilePostToJson $ { pwd: "/home/jacek/", show_hidden: false })
        )
      case response of
        Left error -> FAE.diff
          { resultFiles: (ErrorFile (A.printError error)) }

        Right payload ->
          FAE.diff
            { resultFiles:
                case (jsonToFiles payload.body) of
                  Left _e ->
                    ErrorFile "json error"
                  Right f ->
                    OkFile (f)
            }

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
view model -- { url, result, counter, flags, dirs, resultFiles }
  = HE.main "main"
  [ HE.button [ HA.onClick Decrement ] "-"
  , HE.span
      [ HA.styleAttr
          ( "background-color: "
              <> (bgColor model.counter)
              <> "; "
              <> "margin: auto 1em;"
          )
      ]
      [ HE.text (show model.counter) ]
  , HE.button [ HA.onClick Increment ] "+"
  , HE.br
  , HE.input [ HA.onInput UpdateUrl, HA.value model.url, HA.type' "text" ]
  , HE.button [ HA.onClick Fetch, HA.disabled $ model.result == Fetching ] "Fetch"
  , case model.result of
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
  , HE.p_ (show model.flags)
  , HE.h3_ "model"
  , HE.p_ (show model)
  , HE.button [ HA.onClick FetchFiles, HA.disabled $ model.resultFiles == FetchingFile ] "Fetch Fieles"
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
