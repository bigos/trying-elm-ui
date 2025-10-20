-- module Main where

-- import Prelude

-- import Effect (Effect)
-- import Effect.Console (log)

-- main :: Effect Unit
-- main = do
--   log "🍝"

module Main where

import Prelude

import Effect (Effect)
import Web.DOM.ParentNode (QuerySelector(..))
import Flame (Html, Update, Subscription)
import Flame as F
import Flame.Html.Element as HE
import Flame.Html.Attribute as HA

-- | The model represents the state of the app
type Model = Int

-- | Data type used to represent events
data Message = Increment | Decrement

-- | Initial state of the app
model :: Model
model = 0

-- | `update` is called to handle events
update :: Update Model Message
update model = case _ of
  Increment -> model + 1
  Decrement -> model - 1

-- | `view` is called whenever the model is updated
view :: Model -> Html Message
view model = HE.main [ HA.id "main" ]
  [ HE.button [ HA.onClick Decrement ] [ HE.text "-" ]
  , HE.text $ show model
  , HE.button [ HA.onClick Increment ] [ HE.text "+" ]
  ]

-- | Events that come from outside the `view`
subscribe :: Array (Subscription Message)
subscribe = []

-- | Mount the application on the given selector
main :: Effect Unit
main = F.mount_ (QuerySelector "body")
  { model
  , view
  , update
  , subscribe
  }
