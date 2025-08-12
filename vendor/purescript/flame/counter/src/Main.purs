-- | Example of loading files and displaying them
module Main where

import Prelude

import Affjax.RequestBody (json)
import Affjax.ResponseFormat as AR
import Affjax.Web as A
import Data.Argonaut (decodeJson, encodeJson)
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode.Error (JsonDecodeError, printJsonDecodeError)
import Data.Array (fromFoldable)
import Data.Either (Either(..))
import Data.Int (fromString)
import Data.List (List)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String as DS
import Data.String.Utils (endsWith)
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
  { flags :: Flags
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

type FileObject =
  { name :: String
  , executable :: Boolean
  , extname :: String
  , ftype :: String
  , size :: Int
  , mtime :: String
  , mode :: Int
  , symlink :: Boolean
  }

type Files =
  { pwd :: String
  , show_hidden :: Boolean
  , files :: List FileObject
  }

type Dirs = { leftDir :: Maybe Files, rightDir :: Maybe Files }

type FetchingFilePost =
  { pwd :: String
  , show_hidden :: Boolean
  }

data Message = Initialize Flags | FetchFiles | LoadParent

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
  { flags:
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
      { flags: flags }
    FetchFiles -> do
      display $ FAE.diff'
        { resultFiles: FetchingFile }
      response <-
        ( A.post AR.json ((fromMaybe "" model.flags.base_url) <> "/api/list-files")
            (Just $ json $ fetchingFilePostToJson $ { pwd: "/home/jacek/", show_hidden: false })
        )
      case response of
        Left error -> FAE.diff
          { resultFiles: (ErrorFile (A.printError error))
          , dirs: { leftDir: Nothing, rightDir: Nothing }
          }
        Right payload ->
          case (jsonToFiles payload.body) of
            Left e ->
              FAE.diff
                { resultFiles: ErrorFile (printJsonDecodeError e)
                , dirs: { leftDir: Nothing, rightDir: Nothing }
                }
            Right f ->
              FAE.diff
                { resultFiles: OkFile (f)
                , dirs: { leftDir: Just f, rightDir: Nothing }
                }
    LoadParent -> do
      display $ FAE.diff'
        { resultFiles: FetchingFile }
      response <-
        ( A.post AR.json ((fromMaybe "" model.flags.base_url) <> "/api/list-files")
            ( Just $ json $ fetchingFilePostToJson $
                { pwd:
                    ( case model.dirs.leftDir of
                        Nothing ->
                          "/home/jacek/"
                        Just dir ->
                          --dir.pwd
                          let
                            dpwd = dir.pwd
                          in
                            if dpwd == "/" then "/"
                            else -- "/home/jacek/"
                              ( if endsWith "/" dpwd then "/"
                                else dpwd
                              )
                    )
                , show_hidden:
                    ( case model.dirs.leftDir of
                        Nothing ->
                          false
                        Just dir ->
                          dir.show_hidden
                    )
                }
            )
        )
      case response of
        Left error -> FAE.diff
          { resultFiles: (ErrorFile (A.printError error))
          , dirs: { leftDir: Nothing, rightDir: Nothing }
          }
        Right payload ->
          case (jsonToFiles payload.body) of
            Left e ->
              FAE.diff
                { resultFiles: ErrorFile (printJsonDecodeError e)
                , dirs: { leftDir: Nothing, rightDir: Nothing }
                }
            Right f ->
              FAE.diff
                { resultFiles: OkFile (f)
                , dirs: { leftDir: Just f, rightDir: Nothing }
                }

flagsCounter :: Flags -> Int
flagsCounter flags =
  fromMaybe (-5) (fromString (fromMaybe "" flags.counter_start))

-- *VIEW --

bgColor :: Int -> String
bgColor counter = if counter < 0 then "red" else "lime"

view ∷ Model → Html Message
view model = HE.main "main"
  [ HE.div da_border_green
      [ HE.div (da_border_red)
          [ HE.div (da_border_green) "general toolbar"
          , HE.div [ HA.styleAttr "display: inline-flex" ]
              [ HE.div da_border_red (panel model.dirs.leftDir "left")
              , HE.div da_border_green (panel model.dirs.rightDir "right")
              ]
          ]
      , HE.h3_ "flags"
      , HE.p_ (show model.flags)
      , HE.h3_ "model"
      , HE.p_ (show model)
      , HE.button [ HA.onClick FetchFiles, HA.disabled $ model.resultFiles == FetchingFile ] "Fetch Files"
      ]
  ]

--panel :: forall h. Maybe Files -> String -> Array (Html h)
-- panel
--   :: forall t215 f216 t218
--    . Foldable f216
--   => Maybe
--        { files ::
--            f216
--              { name :: String
--              | t215
--              }
--        | t218
--        }
--   -> String
--   -> Array (Html Message)

panel mFiles side =
  [ HE.div da_border_green
      [ HE.button [ HA.onClick FetchFiles ] "Fetch Files"
      , HE.div da_border_blue (side <> " toolbar")
      ]
  ]
    <>
      ( map (\n -> HE.div_ n)
          ( case mFiles of
              Nothing ->
                [ "nic" ]
              Just f ->
                map (\n -> n.name) (fromFoldable f.files)
          )
      )
    <>
      [ HE.div
          ( [ HA.styleAttr "background: yellow" ]

          )
          (side <> " status")
      ]

da_border_red :: forall t. Array (NodeData t)
da_border_red = da_border_color "red"

da_border_green :: forall t. Array (NodeData t)
da_border_green = da_border_color "green"

da_border_blue :: forall t. Array (NodeData t)
da_border_blue = da_border_color "blue"

da_border_color :: forall t. String -> Array (NodeData t)
da_border_color color = [ HA.styleAttr ("border: solid " <> color <> " 1px") ]

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
