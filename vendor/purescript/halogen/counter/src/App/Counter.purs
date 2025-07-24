module App.Counter where

import Prelude

import Affjax.RequestBody (json)
import Affjax.ResponseFormat as AXRF
import Affjax.Web as AX
import Data.Argonaut (decodeJson, encodeJson, printJsonDecodeError)
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode.Error (JsonDecodeError, printJsonDecodeError)
import Data.Array (fromFoldable)
import Data.Either (Either(..))
import Data.Either (hush)
import Data.Int (fromString)
import Data.List (List)
import Data.Maybe (Maybe(..), fromMaybe)
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP

type State =
  { count :: Int
  , loading :: Boolean
  , result :: Maybe String
  , arg :: TagDataConfig
  , postStatus :: PostStatus
  }

type Files =
  { pwd :: String
  , show_hidden :: Boolean
  , files :: List String
  }

type FetchingFilePost =
  { pwd :: String
  , show_hidden :: Boolean
  }

data PostStatus = Empty | Posting | OkPosted Files | ErrorPosted String

data Action = Increment | Decrement | MakeRequestGet | MakeRequestPost

type TagDataConfig =
  { api_endpoint :: Maybe String
  , api_key :: Maybe String
  , start :: Maybe String
  }

fetchingFilePostToJson :: FetchingFilePost -> Json
fetchingFilePostToJson = encodeJson

jsonToFiles :: Json -> Either JsonDecodeError Files
jsonToFiles = decodeJson

counter_color :: Int -> String
counter_color count =
  if count == 0 then "background: white"
  else (if count < 0 then "background: red" else "background: lime")

outer_style :: String
outer_style =
  ( "display: inline-flex;"
      <> "margin: 1em;"
      <> "padding:1em;"
      <> "background: lightcyan;"
  )

initialState :: TagDataConfig -> State
initialState arg =
  { count:
      ( case arg.start of
          Nothing -> 0
          Just a ->
            ( case fromString a of
                Nothing -> 0
                Just av -> av
            )
      )
  , loading: false
  , result: Nothing
  , arg: arg
  , postStatus: Empty
  }

--component :: forall q i o m. ?whatisit q i o m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval H.defaultEval { handleAction = handleAction }
    }

render :: forall cs m. State -> H.ComponentHTML Action cs m
render state =
  HH.div []
    [ HH.div [ HP.style outer_style, HP.class_ (HH.ClassName "first-class") ]
        [ HH.button
            [ HE.onClick \_ -> Decrement ]
            [ HH.text "-" ]

        , HH.p [ HP.style "background: white; padding: 1em" ]
            [ HH.text "You counted "
            , HH.span [ HP.style ("padding: 0.25em; " <> (counter_color state.count)) ]
                [ HH.text (show state.count) ]
            , HH.text " times"
            ]

        , HH.button
            [ HE.onClick \_ -> Increment ]
            [ HH.text "+" ]

        ]
    , HH.div
        []
        [ HH.p []
            [ HH.button
                [ HE.onClick \_ -> MakeRequestGet ]
                [ HH.text "Get the data" ]
            , HH.button
                [ HE.onClick \_ -> MakeRequestPost ]
                [ HH.text "POST the data" ]
            ]
        , HH.div_
            ( case state.result of
                Nothing -> []
                Just res ->
                  [ HH.h2_
                      [ HH.text "Response:"
                      ]
                  , HH.p_ [ HH.text res ]

                  ]
            )
        ]
    , HH.h3_ [ HH.text "Configured values" ]
    , HH.p [] [ HH.text (show state.arg) ]

    ]

handleAction :: forall output m. MonadAff m => Action -> H.HalogenM State Action () output m Unit
handleAction = case _ of
  Increment -> H.modify_ \st -> st { count = st.count + 1 }
  Decrement -> H.modify_ \st -> st { count = st.count - 1 }
  MakeRequestGet -> do
    H.modify_ \st -> st { loading = true }
    response <- H.liftAff $ AX.get AXRF.string
      ( "http://localhost:3000/api/get-files"
          <> "?"
          <> ("pwd=/home/jacek/" <> "&" <> "show_hidden=true")
      )
    H.modify_ \st -> st
      { loading = false
      , result = map _.body (hush response)
      }
  MakeRequestPost -> do
    H.modify_ \st -> st { postStatus = Posting }
    response <-
      ( AX.post AXRF.json
          ("http://localhost:3000" <> "/api/list-files")
          (Just $ json $ fetchingFilePostToJson $ { pwd: "/home/jacek/", show_hidden: false })
      )
    H.modify_ \st -> st
      { postStatus =
          case response of
            Left error ->
              ErrorPosted (AX.printError error)
            Right payload ->
              case (jsonToFiles payload.body) of
                Left e ->
                  ErrorPosted (printJsonDecodeError e)
                Right f ->
                  OkPosted (f)
      }
