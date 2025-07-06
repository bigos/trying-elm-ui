module UiExperiment exposing (Model)

import Browser
import Element exposing (Color, Element, alignRight, centerY, column, el, fill, height, html, htmlAttribute, inFront, layout, mouseDown, mouseOver, moveRight, padding, px, rgb255, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes as HA
import Http
import Json.Decode as Decode exposing (Decoder, decodeString, field, float, int, map4, nullable, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- TYPES


type alias Model =
    { toggle : Bool
    , dir : Files
    }


type alias Flags =
    ()


type alias Files =
    { pwd : List String
    , showHidden : Bool
    , files : Maybe (List String)
    }


type alias File =
    { name : String }



-- INIT


new_model : Model
new_model =
    { toggle = True
    , dir =
        { pwd = [ "~" ]
        , showHidden = False
        , files = Nothing
        }
    }


init : Flags -> ( Model, Cmd Msg )
init _ =
    let
        m =
            new_model
    in
    ( m, Cmd.none )



-- UPDATE


type Msg
    = Toggle
    | LoadFiles
    | LoadedFiles (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Toggle ->
            ( { model | toggle = not model.toggle }, Cmd.none )

        LoadFiles ->
            ( model, httpLoadFiles model )

        LoadedFiles result ->
            -- TODO add rails response with  the files and convert the response later from string to sensible json
            case result of
                Ok fullText ->
                    Debug.log (Debug.toString fullText)
                        ( { model
                            | dir =
                                { pwd = [ "todo" ]
                                , showHidden = False
                                , files = Just [ fullText ]
                                }
                          }
                        , Cmd.none
                        )

                Err errMsg ->
                    Debug.log (Debug.toString errMsg)
                        ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    -- elm-ui layout
    layout
        []
        (column []
            [ text "Hello Elm-UI!"

            -- , Element.text (Debug.toString model)
            , Input.checkbox [ padding 10 ] <|
                { onChange = always Toggle
                , label = Input.labelRight [] (text "Switch colours")
                , checked = model.toggle
                , icon =
                    toggleCheckboxWidget
                        { offColor = lightGrey
                        , onColor = green
                        , sliderColor = white
                        , toggleWidth = 60
                        , toggleHeight = 28
                        }
                }
            , myRowOfStuff model
            , html (Html.hr [] [])
            , Input.button
                [ padding 10
                , Border.width 3
                , Border.rounded 6
                , Border.color color.blue
                , Background.color color.lightBlue
                , Font.variant Font.smallCaps

                -- The order of mouseDown/mouseOver can be significant when changing
                -- the same attribute in both
                , mouseDown
                    [ Background.color color.blue
                    , Border.color color.blue
                    , Font.color color.white
                    ]
                , mouseOver
                    [ Background.color color.white
                    , Border.color color.lightGrey
                    ]
                ]
                { onPress = Just LoadFiles, label = text "Load Files" }
            , html (Html.hr [] [])
            , text (Debug.toString model)
            ]
        )


color =
    { blue = rgb255 0x72 0x9F 0xCF
    , darkCharcoal = rgb255 0x2E 0x34 0x36
    , lightBlue = rgb255 0xC5 0xE8 0xF7
    , lightGrey = rgb255 0xE0 0xE0 0xE0
    , white = rgb255 0xFF 0xFF 0xFF
    }


toggleCheckboxWidget : { offColor : Color, onColor : Color, sliderColor : Color, toggleWidth : Int, toggleHeight : Int } -> Bool -> Element msg
toggleCheckboxWidget { offColor, onColor, sliderColor, toggleWidth, toggleHeight } checked =
    el
        [ Background.color <|
            if checked then
                onColor

            else
                offColor
        , width <| px <| toggleWidth
        , height <| px <| toggleHeight
        , Border.rounded 14
        , inFront <|
            el [ height fill ] <|
                el
                    (let
                        pad =
                            3

                        sliderSize =
                            toggleHeight - 2 * pad
                     in
                     [ Background.color sliderColor
                     , Border.rounded <| sliderSize // 2
                     , width <| px <| sliderSize
                     , height <| px <| sliderSize
                     , centerY
                     , moveRight pad
                     , htmlAttribute <|
                        HA.style "transition" ".4s"
                     , htmlAttribute <|
                        if checked then
                            let
                                translation =
                                    String.fromInt
                                        (toggleWidth - sliderSize - pad)
                            in
                            HA.style "transform" <| "translateX(" ++ translation ++ "px)"

                        else
                            HA.class ""
                     ]
                    )
                <|
                    text ""
        ]
    <|
        text ""


lightGrey : Color
lightGrey =
    rgb255 187 187 187


green : Color
green =
    rgb255 39 203 139


white : Color
white =
    rgb255 255 255 255


myRowOfStuff : Model -> Element msg
myRowOfStuff model =
    row [ width fill, centerY, spacing 30 ]
        [ myElement model
        , myElement model
        , el [ alignRight ] (myElement model)
        ]


myElement : Model -> Element msg
myElement model =
    el
        [ Background.color
            (if model.toggle then
                rgb255 57 180 111

             else
                rgb255 111 120 97
            )
        , Font.color (rgb255 255 255 255)
        , Border.rounded 3
        , padding 30
        ]
        (Element.text "stylish!")



-- ACTIONS


httpLoadFiles model =
    Http.post
        { url = "http://localhost:3000/api/list-files"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "pwd", Encode.string "/home/jacek" )
                    , ( "show_hidden", Encode.bool False )
                    ]
                )

        -- , expect = Http.expectJson LoadedFiles fileListDecoder
        , expect = Http.expectString LoadedFiles
        }


fileListDecoder =
    Debug.todo "write decoder"



-- Decode.succeed
-- file:~/Programming/Pyrulis/Elm/readingElmInAction/PhotoGroove/src/PhotoFolders.elm::214
