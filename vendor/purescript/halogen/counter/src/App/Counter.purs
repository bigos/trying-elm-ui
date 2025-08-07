module App.Counter where

import Prelude

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
import Data.List (List, length)
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
  , loading :: Boolean
  , result :: Maybe String
  , arg :: TagDataConfig
  , postStatus :: PostStatus
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

type FetchingFilePost =
  { pwd :: String
  , show_hidden :: Boolean
  }

data PostStatus = Empty | OkPosted Files | ErrorPosted String

derive instance genericPostStatus :: Generic PostStatus _

instance showPostStatus :: Show PostStatus where
  show = genericShow

data Action = Increment | Decrement | MakeRequestGet | MakeRequestPost | LoadParent | LoadChild

type TagDataConfig =
  { api_endpoint :: Maybe String
  , api_key :: Maybe String
  , start :: Maybe String
  }

fetchingFilePostToJson :: FetchingFilePost -> Json
fetchingFilePostToJson = encodeJson

jsonToFiles :: Json -> Either JsonDecodeError Files
jsonToFiles = decodeJson

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

component
  :: forall output410 m411 t425
   . MonadAff m411
  => Component t425
       { api_endpoint :: Maybe String
       , api_key :: Maybe String
       , start :: Maybe String
       }
       output410
       m411
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
    , HH.h3_ [ HH.text "model" ]
    , HH.p [] [ HH.text (show state) ]
    , HH.div (da_border_color "green")
        [ HH.div (da_border_color "red")
            [ HH.div (da_border_color "green") [ HH.text "general toolbar" ]
            , HH.div [ HP.style "display: inline-flex" ]
                [ HH.div (da_border_color "red") (panel state "left")
                , HH.div (da_border_color "green") (panel state "right")
                ]
            ]
        ]
    ]

data ZzzValue = Fob FileObject | Str String

--zzz :: forall w i. ZzzValue -> HTML w i
--zzz :: forall w31. ZzzValue -> HTML w31 Action
zzz n = case n of
  Str str ->
    HH.text str
  Fob fileobject ->
    if fileobject.ftype == "directory" then
      HH.button
        [ HE.onClick \_ -> LoadChild ]
        [ HH.text fileobject.name ]
    else
      HH.span [] [ HH.text fileobject.name ]

panel :: forall w254 t279. { postStatus :: PostStatus | t279 } -> String -> Array (HTML w254 Action)
panel state side =
  [ HH.div (da_border_color "blue")
      [ HH.button
          -- why this won't work
          [ HE.onClick \_ -> LoadParent ]
          [ HH.text "Parent" ]
      , HH.text (side <> " toolbar")
      ]
  ]
    <>
      ( map
          ( \n -> HH.div []
              [ zzz n
              ]
          )
          ( if side == "right" then [ Str "" ]
            else
              ( case state.postStatus of
                  OkPosted fx ->
                    (map (\f -> Fob f) (fromFoldable fx.files))
                  _ ->
                    [ Str "" ]
              )
          )
      )
    <> [ HH.div [ HP.style "background: yellow" ] [ HH.text (side <> " status") ] ]

da_border_color
  :: forall r227 i228
   . String
  -> Array
       ( IProp
           ( style :: String
           | r227
           )
           i228
       )
da_border_color color = [ HP.style ("border: solid " <> color <> " 1px") ]

parent_thepwd :: String -> String
parent_thepwd pwd =
  if pwd == "/" then "/"
  else
    let
      pwd2 =
        ( if endsWith "/" pwd then
            DS.take (DS.length pwd - 1) pwd
          else pwd
        )
      splitPwd2 =
        (DS.split (DS.Pattern "/") pwd2)
      joined =
        ( joinWith "/"
            ( DA.take (DA.length splitPwd2 - 1) splitPwd2
            )
        )
    in
      if joined == "" then "/" else joined

parent_pwd :: State -> String
parent_pwd sta =
  case sta.postStatus of
    OkPosted files -> parent_thepwd files.pwd
    _ -> "/home/jacek"

child_pwd :: State -> String -> String
child_pwd sta child =
  case sta.postStatus of
    OkPosted files -> files.pwd -- <> "/" <> child
    _ -> "/home/jacek"

--handleAction :: forall output m. MonadAff m => Action -> H.HalogenM State Action () output m Unit
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
    --sta <- H.get -- get the state
    response <- H.liftAff $
      ( AX.post AXRF.json ("http://localhost:3000" <> "/api/list-files")
          ( Just $ AXRB.json $ fetchingFilePostToJson $
              -- how do I access state?
              { pwd: ("/home/jacek/")
              , show_hidden: false
              }
          )
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
  LoadParent -> do
    sta <- H.get
    response <- H.liftAff $
      ( AX.post AXRF.json ("http://localhost:3000" <> "/api/list-files")
          ( Just $ AXRB.json $ fetchingFilePostToJson $ -- how do I access state?
              { pwd: (parent_pwd sta)
              , show_hidden: false
              }
          )
      )
    H.modify_ \st -> st
      { postStatus = case response of
          Left error -> ErrorPosted (AX.printError error)
          Right payload ->
            case (jsonToFiles payload.body) of
              Left e ->
                ErrorPosted (printJsonDecodeError e)
              Right f ->
                OkPosted (f)
      }
  LoadChild -> do
    sta <- H.get
    response <- H.liftAff $
      ( AX.post AXRF.json ("http://localhost:3000" <> "/api/list-files")
          ( Just $ AXRB.json $ fetchingFilePostToJson $ -- how do I access state?
              { pwd: (parent_pwd sta)
              , show_hidden: false
              }
          )
      )
    H.modify_ \st -> st
      { postStatus = case response of
          Left error -> ErrorPosted (AX.printError error)
          Right payload ->
            case (jsonToFiles payload.body) of
              Left e ->
                ErrorPosted (printJsonDecodeError e)
          Right f ->
            OkPosted (f)
      }
