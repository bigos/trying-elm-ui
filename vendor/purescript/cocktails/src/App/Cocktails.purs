module App.Cocktails where

import Prelude
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Data.Int (fromString)
import Data.Maybe (Maybe, fromMaybe)
import Data.String (joinWith)

type State =
  { count :: Int
  , flags :: Flags
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
      ( fromMaybe 0
          ( fromString
              ( fromMaybe "0" flags.logname
              )
          )
      )
  , flags: flags
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
    ]

handleAction :: forall cs o m. Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of
  Increment -> H.modify_ \st -> st { count = st.count + 1 }

-- ===================================================
displayFlags :: Flags -> String
displayFlags flags =
  joinWith ", "
    [ "start: " <> (fromMaybe "" flags.start)
    , "logname: " <> (fromMaybe "" flags.logname)
    , "base_url: " <> (fromMaybe "" flags.base_url)
    ]
