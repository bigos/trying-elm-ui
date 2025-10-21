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
import Data.Array as DA
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
import Web.HTML.HTMLInputElement (value, fromElement)

-- *TYPES --

type Model =
  { flags :: Flags
  , dirs :: Dirs
  , resultFiles :: ResultFiles
  , resultDrinks :: ResultDrinks
  , selected :: String
  }

type Flags =
  { start :: Maybe String
  , base_url :: Maybe String
  , logname :: Maybe String
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

type Drinks =
  { drinks :: List Drink }

type Drink =
  { strDrink :: String
  , strInstructions :: String
  , strDrinkThumb :: String
  }

data Message = Initialize Flags | FetchFiles | LoadParent | LoadChild String | FetchDrinks | DebugInput String

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

data ResultDrinks = NotFetchedDrink | FetchingDrinks | OkDrinks Drinks | ErrorDrink String

derive instance eqResultDrinks ∷ Eq ResultDrinks
instance showResultDrinks :: Show (ResultDrinks) where
  show :: ResultDrinks -> String
  show (NotFetchedDrink) = "NotFetchedDrink"
  show (FetchingDrinks) = "FetchingDrinks"
  show (OkDrinks a) = "OkDrinks " <> show a
  show (ErrorDrink a) = "ErrorDrink " <> show a

-- *INIT --

init ∷ Model
init =
  { flags:
      { start: Nothing
      , base_url: Nothing
      , logname: Nothing
      }
  , dirs: { leftDir: Nothing, rightDir: Nothing }
  , resultFiles: NotFetchedFile
  , resultDrinks: NotFetchedDrink
  , selected: ""
  }

-- *UPDATE --

fetchingFilePostToJson :: FetchingFilePost -> Json
fetchingFilePostToJson = encodeJson

jsonToFiles :: Json -> Either JsonDecodeError Files
jsonToFiles = decodeJson

jsonToDrinks :: Json -> Either JsonDecodeError Drinks
jsonToDrinks = decodeJson

update ∷ AffUpdate Model Message
update { display, model, message } =
  case message of
    Initialize flags -> FAE.diff
      { flags: flags
      , selected: ""
      }
    DebugInput input_id -> do
      -- https://pursuit.purescript.org/packages/purescript-web-html/4.1.0/docs/Web.HTML.HTMLInputElement
      w <- window
      doc <- document w
      container <- getElementById input_id $ toNonElementParentNode doc
      case container of
        Nothing ->
          FAE.diff { selected: "container element not found" }
        Just element ->
          ( case fromElement element of
              Nothing ->
                FAE.diff { selected: "element is not input element" }
              Just iel ->
                FAE.diff { selected: (value iel) }
          )

    FetchDrinks -> do
      display $ FAE.diff'
        { resultDrinks: FetchingDrinks }
      response <-
        -- TODO
        ( A.get AR.json --((fromMaybe "" model.flags.base_url) <> "/api/list-files")
            ( "https://thecocktaildb.com/api/json/v1/1/search.php?s=" <>
                if true then
                  "rum"
                else
                  "Rum Runner"
            )
        )
      case response of
        Left error -> FAE.diff
          { resultDrinks: (ErrorDrink (A.printError error)) }
        Right payload ->
          case (jsonToDrinks payload.body) of
            Left e ->
              FAE.diff
                { resultDrinks: ErrorDrink (printJsonDecodeError e) }
            Right f ->
              FAE.diff
                { resultDrinks: OkDrinks (f) }
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
                          let
                            dpwd = dir.pwd
                            pwd2 =
                              if dpwd == "/" then "/"
                              else -- "/home/jacek/"
                                ( if endsWith "/" dpwd then
                                    DS.take ((DS.length dpwd) - 1) dpwd
                                  else dpwd
                                )
                            splitPwd2 = (DS.split (DS.Pattern "/") pwd2)
                            joined = (DS.joinWith "/" (DA.take (DA.length splitPwd2 - 1) splitPwd2))
                          in
                            if joined == "" then "/" else joined
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
    LoadChild child -> do
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
                          dir.pwd <> "/" <> child

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
  fromMaybe (-5) (fromString (fromMaybe "" flags.start))

-- *VIEW --

bgColor :: Int -> String
bgColor counter = if counter < 0 then "red" else "lime"

-- try this
-- https://gomakethings.com/how-to-create-an-autocomplete-input-with-only-html/
view ∷ Model → Html Message
view model = HE.main "main"
  [ HE.div_
      [ HE.label [ HA.for "nums" ] [ HE.text "What is your order?" ]
      , HE.input
          [ HA.id "nums"
          , HA.type' "text"
          , HA.name "nums"
          , HA.list "numlist"
          , HA.onClick (DebugInput "nums")
          ]

      , ( case model.resultDrinks of
            OkDrinks dx ->
              ( HE.datalist
                  [ HA.id "numlist" ]
                  ( DA.fromFoldable
                      ( map (\i -> HE.option_ i.strDrink)
                          dx.drinks
                      )
                  )
              )
            _ -> HE.span_ ""
        )
      ]
  , HE.div_
      ( case model.resultDrinks of
          OkDrinks dx ->
            [ HE.ol_
                ( DA.fromFoldable
                    ( map
                        ( \i ->
                            HE.li_
                              [ HE.div_
                                  [ HE.h3_ i.strDrink

                                  , HE.img
                                      [ HA.src i.strDrinkThumb
                                      , HA.alt (i.strDrink)
                                      ]
                                  , HE.p_ i.strInstructions

                                  ]
                              ]
                        )

                        dx.drinks
                    )
                )
            ]
          _ ->
            [ HE.p_ (show (model.resultDrinks)) ]
      )
  , HE.button
      [ HA.onClick FetchDrinks, HA.disabled $ model.resultDrinks == FetchingDrinks ]
      "Fetch Cocktails"
  , HE.div da_border_green
      [ HE.h3_ "flags"
      , HE.p_ (show model.flags)
      , HE.h3_ "model"
      , HE.p_ (show model)
      ]
  ]

panel :: Maybe Files -> String -> Array (Html Message)
panel mFiles side =
  [ HE.div da_border_green
      [ HE.button [ HA.onClick LoadParent ] "Parent"
      , HE.span_
          ( case mFiles of
              Nothing -> ""
              Just f -> f.pwd
          )
      , HE.div da_border_blue (side <> " toolbar")
      ]
  ]
    <>
      panelInner mFiles

    <>
      [ HE.div
          ( [ HA.styleAttr "background: yellow" ]

          )
          (side <> " status")
      ]

panelInner :: Maybe Files -> Array (Html Message)
panelInner mFiles =
  ( case mFiles of
      Nothing -> []
      Just f -> panelInnerJust f

  )

panelInnerJust :: Files -> Array (Html Message)
panelInnerJust f =
  map
    ( \n ->
        if n.ftype == "directory" then
          HE.div_
            [ (HE.button [ HA.onClick (LoadChild n.name) ] n.name)
            ]
        else
          (HE.div_ n.name)

    )
    (fromFoldable f.files)

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
  let outputTag = "#flame-cocktail"
  let configTagId = "flame-cocktail-flags"
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
        ( { start: _, base_url: _, logname: _ }
            <$> getAttribute "data-start" element
            <*> getAttribute "data-base-url" element
            <*> getAttribute "data-logname" element
        )
