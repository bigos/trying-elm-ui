module App.Cocktails where

import Prelude
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Data.Maybe (Maybe(..))
import Data.Int (fromString)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Maybe (Maybe, fromJust)

type State =
  { count :: Int
  , logname :: String
  , base_url :: String
  }

type Flags =
  { start :: Maybe String
  , logname :: Maybe String
  , base_url :: Maybe String
  }

data Action = Increment

initialState :: Flags -> State
initialState flags =
  { count:
      ( case flags.start of
          Nothing -> 0
          Just a ->
            ( case fromString a of
                Nothing -> 0
                Just av -> av
            )
      )
  , logname: fromMaybe "" flags.logname
  , base_url: fromMaybe "" flags.base_url
  }

--component :: forall q i o m. H.Component q i o m
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
    ]

handleAction :: forall cs o m. Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of
  Increment -> H.modify_ \st -> st { count = st.count + 1 }
