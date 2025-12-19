module App.Cocktails where

import Prelude

-- import Affjax.RequestBody as AXRB
import Data.Functor.Compose (Compose(..))
import Data.Traversable (for)
import Data.Argonaut (decodeJson)
import Data.Argonaut (class DecodeJson)
import Data.Argonaut.Decode.Combinators ((.:), (.:?))
import Data.Argonaut.Decode.Decoders as Json.Decoders
-- import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode.Error (printJsonDecodeError)
import Data.Array as DA
import Data.Generic.Rep (class Generic)
import Data.List (List, length)
-- import Data.Show (show)
import Data.Show.Generic (genericShow)
import Data.String (joinWith)
import Data.String as DS
-- import Data.String.Utils (endsWith)
-- import Data.Tuple (Tuple, fst, snd)
-- import Debug (trace, spy, traceM)
import Effect.Aff.Class (class MonadAff)
-- import Halogen.Component (Component)
-- import Halogen.HTML.Core (HTML)
import Affjax.ResponseFormat as AXRF
import Affjax.Web as AX
import Data.Either (Either(..))
import Data.Int (fromString)
import Data.Maybe (Maybe(..), fromMaybe)
-- import Data.String.Common (joinWith)
-- import Effect.Console (logShow)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Web.UIEvent.KeyboardEvent as KE

type State =
  { count :: Int
  , flags :: Flags
  , loading :: Boolean
  , result :: Maybe String
  , getStatus :: GetStatus
  , selected :: String
  , key :: String
  }

type Flags =
  { start :: Maybe String
  , logname :: Maybe String
  , base_url :: Maybe String
  }

data GetStatus = GetEmpty | GetError String | GetOk Drinks

derive instance genericGetStatus :: Generic GetStatus _
instance showGetStatus :: Show GetStatus where
  show = genericShow

type Drinks =
  { the_list :: List Drink }

newtype Drink = Drink
  { strDrink :: String
  , strInstructions :: String
  , strDrinkThumb :: String
  , strIngredients :: Array String

  }

instance DecodeJson Drink where
  decodeJson json = do
    object <- Json.Decoders.decodeJObject json
    strDrink <- object .: "strDrink"
    strInstructions <- object .: "strInstructions"
    strDrinkThumb <- object .: "strDrinkThumb"
    strIngredients <- do
      fields <- for (1 DA... 15) \index ->
        object .:? ("strIngredient" <> show index)
      pure $ DA.fromFoldable (Compose fields)
    pure $
      Drink
        { strDrink, strInstructions, strDrinkThumb, strIngredients }

derive instance Generic Drink _
instance Show Drink where
  show = genericShow

data Action
  = Increment
  | MakeRequestGet
  | DebugInput String
  | DebugKeydown KE.KeyboardEvent

initialState :: Flags -> State
initialState flags =
  { count:
      ( fromMaybe 0
          ( fromString
              (fromMaybe "0" flags.logname)
          )
      )
  , flags: flags
  , loading: false
  , result: Nothing
  , getStatus: GetEmpty
  , selected: ""
  , key: ""
  }

component
  :: forall output235 m236 t251
   . MonadAff m236
  => H.Component t251
       { base_url :: Maybe String
       , logname :: Maybe String
       , start :: Maybe String
       }
       output235
       m236
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval H.defaultEval { handleAction = handleAction }
    }

render state =
  hh.div_
    [ hh.p_
        [ hh.text $ "you clicked " <> show state.count <> " times" ]
    , hh.button
        [ he.onclick \_ -> increment ]
        [ hh.text "click me" ]
    , hh.hr_
    , hh.h5_ [ hh.text "input search" ]
    , hh.p []
        [ hh.input
            [ he.onvalueinput \str -> (debuginput str)
            , he.onkeydown (debugkeydown)
            ]
        ]
    , hh.hr_
    , hh.h5_ [ hh.text "flags" ]
    , hh.p [] [ hh.text (displayflags state.flags) ]
    , hh.p [] [ hh.text (show state.key) ]
    , hh.p [] [ hh.text (show state.selected) ]
    , hh.p []
        [ hh.button
            [ he.onclick \_ -> makerequestget

            ]
            [ hh.text "get the data" ]
        ]
    , hh.p [] [ hh.text (frommaybe "" state.result) ]
    , hh.p []
        [ hh.text
            ( case state.getstatus of
                getempty -> "empty get status"
                geterror str -> str
                getok d ->
                  ( "got "
                      <> show (length d.the_list)
                      <> " drinks"
                  )
            )
        ]
    , hh.div []
        ( case state.getstatus of
            getok drinks ->
              ( da.fromfoldable
                  ( map
                    ( \i ->
                          HH.div []
                            [ HH.div [ HP.style "background: CornSilk; padding: 1em; margin: 1em; width: 60em" ]
                                [ HH.h2 [] [ HH.text i.strDrink ]
                                , HH.img [ HP.src i.strDrinkThumb, HP.alt (i.strDrink) ]
                                , HH.h3 [] [ HH.text "Ingredients" ]
                                , HH.p [] [ HH.text (joinWith ", " i.strIngredients) ]
                                , HH.h3 [] [ HH.text "Instructions" ]
                                , HH.p [] [ HH.text i.strInstructions ]
                                ]

                            ]
                      )
                      drinks.the_list
                  )
              )
            _ ->
              []
        )
    ]

-- handleAction :: Action -> H.HalogenM State _ () _ _ Unit
handleAction :: forall output m. MonadAff m => Action -> H.HalogenM State Action () output m Unit
handleAction = case _ of
  Increment -> H.modify_ \st -> st { count = st.count + 1 }
  DebugKeydown input_key ->
    let
      key = (KE.key input_key)
    -- val = spy "val" (KE.code input_key)
    in
      if (key == "Enter") then
        handleAction MakeRequestGet
      else if key == "Escape" then
        H.modify_ \st -> st { selected = "" }
      else
        -- do nothing
        H.modify_ \st -> st { count = st.count }
  DebugInput input_str -> H.modify_ \st -> st { selected = input_str }
  MakeRequestGet ->
    do
      newState <- H.modify \st -> (st { loading = true })

      response <- H.liftAff $ AX.get
        --AXRF.string
        AXRF.json
        ( "https://thecocktaildb.com/api/json/v1/1/search.php?s=" <>
            -- how do i read State here?
            ( if ((DS.length newState.selected) >= 3) then
                newState.selected
              else
                "Rum Runner"
            )

        )
      H.modify_ \st -> st
        { loading = false
        --  , result = map _.body (hush response)
        , getStatus = handleResponse response
        }
    where
    handleResponse resp =
      case resp of
        Left error ->
          GetError (AX.printError error)
        Right payload ->
          case
            (decodeJson payload.body)
            of
            Left e ->
              GetError (printJsonDecodeError e)
            Right f ->
              GetOk f

displayFlags :: Flags -> String
displayFlags flags =
  -- Just like Elm's Debug.toString
  show flags
