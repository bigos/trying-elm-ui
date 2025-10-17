module App.Cocktails where

import Prelude

import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Data.Int (fromString)
import Data.Maybe (Maybe, fromMaybe)
import Data.String (joinWith)
import Affjax.RequestBody as AXRB
import Affjax.ResponseFormat as AXRF
import Affjax.Web as AX
import Data.Argonaut (decodeJson, encodeJson)
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode.Error (JsonDecodeError, printJsonDecodeError)
import Data.Array (fromFoldable)
import Data.Array as DA
import Data.Either (Either(..), hush)
import Data.Generic.Rep (class Generic)
import Data.Int (fromString)
import Data.List (List)
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)
import Data.String as DS
import Data.String.Common (joinWith)
import Data.String.Utils (endsWith)
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.Component (Component)
import Halogen.HTML as HH
import Halogen.HTML.Core (HTML)
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties (IProp)
import Halogen.HTML.Properties as HP

type State =
  { count :: Int
  , flags :: Flags
  , loading :: Boolean
  , result :: Maybe String
  }

type Flags =
  { start :: Maybe String
  , logname :: Maybe String
  , base_url :: Maybe String
  }

data Action = Increment | MakeRequestGet

initialState :: Flags -> State
initialState flags =
  { count:
      ( fromMaybe 0
          ( fromString
              ( fromMaybe "0" flags.logname
              )
          )
      )
  , flags: flags
  , loading: false
  , result: Nothing
  }

component :: forall output m t. H.Component t Flags output m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval H.defaultEval { handleAction = handleAction }
    }

render :: forall cs m. State -> H.ComponentHTML Action cs m
render state =
  HH.div_
    [ HH.p_
        [ HH.text $ "You clicked " <> show state.count <> " times" ]
    , HH.button
        [ HE.onClick \_ -> Increment ]
        [ HH.text "Click me" ]
    , HH.hr_
    , HH.h5_ [ HH.text "Flags" ]
    , HH.p [] [ HH.text (displayFlags state.flags) ]
    , HH.p []
        [ HH.button
            [ HE.onClick \_ -> MakeRequestGet ]
            [ HH.text "Get the data" ]
        ]
    ]

handleAction :: forall o m. Action → H.HalogenM State Action () o m Unit
handleAction = case _ of
  Increment -> H.modify_ \st -> st { count = st.count + 1 }
  MakeRequestGet -> do
    H.modify_ \st -> st { loading = true }
    response <- H.liftAff $ AX.get AXRF.string
      ( "https://thecocktaildb.com/api/json/v1/1/search.php?s="
          <> "rum"
      )
    --url = "https://thecocktaildb.com/api/json/v1/1/search.php?s=" ++ String.replace " " "+" query
    H.modify_ \st -> st
      { loading = false
      , result = map _.body (hush response)
      }

-- ===================================================
displayFlags :: Flags -> String
displayFlags flags =
  joinWith ", "
    [ "start: " <> (fromMaybe "" flags.start)
    , "logname: " <> (fromMaybe "" flags.logname)
    , "base_url: " <> (fromMaybe "" flags.base_url)
    ]
