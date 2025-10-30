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
import Data.List (List, length)
import Data.Tuple (Tuple, fst, snd)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String as DS
import Data.String.Utils (endsWith)
import Debug (trace)
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
  , resultDrinks :: ResultDrinks
  , selected :: String
  , key :: String
  }

type Flags =
  { start :: Maybe String
  , base_url :: Maybe String
  , logname :: Maybe String
  }

type Drinks =
  { drinks :: List Drink }

type Drink =
  { strDrink :: String
  , strInstructions :: String
  , strDrinkThumb :: String
  }

data Message
  = Initialize Flags
  | FetchDrinks
  | DebugKeydown (Tuple String String)
  | DebugInput String

instance showMessage :: Show (Message) where
  show :: Message -> String
  show (Initialize a) = "Initialize " <> show a
  show (FetchDrinks) = "FetchDrinks"
  show (DebugKeydown a) = "DebugKeydown " <> show a
  show (DebugInput a) = "DebugInput " <> show a

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
  , resultDrinks: NotFetchedDrink
  , selected: ""
  , key: ""
  }

-- *UPDATE --

jsonToDrinks :: Json -> Either JsonDecodeError Drinks
jsonToDrinks = decodeJson

drinks_stats resultDrinks =
  ( case resultDrinks of
      NotFetchedDrink -> "Notfetcheddrink"
      FetchingDrinks -> "Fetchdrinks"
      OkDrinks drinks -> show { length: length drinks.drinks }
      ErrorDrink error -> error
  )

update ∷ AffUpdate Model Message
update { display, model, message } =
  let
    updateMessage = show
      { message: show message
      , selected: model.selected
      , key: model.key
      , drinks: drinks_stats model.resultDrinks

      }
  in
    trace updateMessage \_ ->
      ( case message of
          Initialize flags -> FAE.diff
            { flags: flags
            , selected: ""
            }
          DebugKeydown input_tuple ->
            let
              key = fst input_tuple
              val = snd input_tuple
            in
              if key == "Enter" then
                update { display: display, model: model, message: FetchDrinks }
              else if key == "Escape" then
                FAE.diff { selected: "", key: key }
              else
                FAE.diff { selected: (val), key: key }

          DebugInput input_str -> FAE.diff { selected: input_str }

          FetchDrinks -> do
            display $ FAE.diff'
              { resultDrinks: FetchingDrinks }
            response <-
              -- TODO
              ( A.get AR.json --((fromMaybe "" model.flags.base_url) <> "/api/list-files")
                  ( "https://thecocktaildb.com/api/json/v1/1/search.php?s=" <>
                      if DS.length (model.selected) >= 3 then
                        model.selected
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
                    trace (show { fetched_length: (length f.drinks) }) \_ ->
                      FAE.diff
                        { resultDrinks: OkDrinks (f) }
      )

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
      [ HE.p_ (drinks_stats model.resultDrinks)
      , HE.p_ model.selected
      , HE.p_ model.key
      , HE.label [ HA.for "nums" ] [ HE.text "What is your order?" ]
      , view_input model
      , view_options model
      ]
  , view_drinks model
  , HE.div (da_border_color "green")
      [ HE.h3_ "flags"
      , HE.p_ (show model.flags)
      , HE.h3_ "model"
      , HE.p_ (show model)
      ]
  ]

view_drinks model =
  HE.div_
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
                                    , HA.width "100"
                                    , HA.height "auto"
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
        _ -> [ HE.p_ (show (model.resultDrinks)) ]
    )

view_input model =
  HE.input
    [ HA.id "nums"
    , HA.type' "text"
    , HA.name "nums"
    , HA.list "numlist"
    , HA.value (model.selected)
    , HA.onInput (DebugInput)
    , HA.onKeydown (DebugKeydown)
    ]

view_options model =
  ( case model.resultDrinks of
      OkDrinks dx ->
        ( HE.datalist
            [ HA.id "numlist" ]
            ( DA.fromFoldable
                ( map (\i -> HE.option_ i.strDrink)
                    dx.drinks
                )
            )
        )
      _ -> HE.span_ "nothing loaded"
  )

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
