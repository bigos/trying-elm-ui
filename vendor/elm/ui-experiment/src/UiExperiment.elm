module UiExperiment exposing (Files, Model)

import Browser
import Element exposing (Color, Element, alignRight, alignTop, centerY, column, el, fill, height, html, htmlAttribute, inFront, layout, mouseDown, mouseOver, moveRight, padding, paragraph, px, rgb, rgb255, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes as HA
import Http
import Json.Decode as Decode exposing (Decoder, bool, decodeString, field, float, int, list, map4, nullable, string)
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
    , flags : Flags
    , dirs : Dirs
    }


type alias Flags =
    { base_url : String
    , logname : String
    , home : String
    , showHidden : Bool
    }


type alias Files =
    { pwd : String
    , showHidden : Bool
    , files : List String
    }


type alias Dirs =
    { leftDir : Maybe Files
    , rightDir : Maybe Files
    }



-- INIT


new_model : Flags -> Model
new_model flags =
    { toggle = True
    , dirs = { leftDir = Nothing, rightDir = Nothing }
    , flags = flags
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        m =
            new_model flags
    in
    ( m, Cmd.none )



-- UPDATE


type Msg
    = Toggle
    | LoadFiles
    | LoadedFiles (Result Http.Error Files)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Toggle ->
            ( { model | toggle = not model.toggle }, Cmd.none )

        LoadFiles ->
            ( model, httpLoadFiles model )

        LoadedFiles result ->
            case result of
                Ok fullText ->
                    Debug.log (Debug.toString fullText)
                        ( { model
                            | dirs =
                                buildOnlyLeftDir { pwd = fullText.pwd, showHidden = fullText.showHidden, files = fullText.files }
                          }
                        , Cmd.none
                        )

                Err errMsg ->
                    Debug.log (Debug.toString errMsg)
                        ( model, Cmd.none )


buildOnlyLeftDir : Files -> Dirs
buildOnlyLeftDir dir =
    { leftDir = Just dir
    , rightDir = Nothing
    }


buildOnlyRightDir : Files -> Dirs
buildOnlyRightDir dir =
    { leftDir = Nothing
    , rightDir = Just dir
    }


buildBothDirs : Files -> Files -> Dirs
buildBothDirs dirLeft dirRight =
    { leftDir = Just dirLeft
    , rightDir = Just dirRight
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


my_border =
    [ Border.width 1, Border.color color.blue ]


file_panel : Model -> String -> Element msg
file_panel model lr =
    let
        lrdir =
            if lr == "left" then
                model.dirs.leftDir

            else
                model.dirs.rightDir
    in
    column
        ([ alignTop ]
            ++ my_border
        )
        [ case lrdir of
            Nothing ->
                el ([ Background.color color.lightBlue ] ++ my_border) (text ("toolbar " ++ lr))

            Just files ->
                el ([ Background.color color.lightBlue ] ++ my_border) (text files.pwd)
        , case lrdir of
            Nothing ->
                el my_border (text "No files")

            Just files ->
                panel_files model files
        ]


file_panel_left : Model -> Element msg
file_panel_left model =
    file_panel model "left"


file_panel_right : Model -> Element msg
file_panel_right model =
    file_panel model "right"


panel_files : Model -> Files -> Element msg
panel_files model files =
    column []
        (List.map
            (\x -> el [] (text x))
            (List.sort files.files)
        )


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
                , label = Input.labelRight [] (text "Switch Toggle")
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
            , el [ padding 20 ]
                (column
                    ([ alignTop ] ++ my_border)
                    [ el [] (text "general toolbar")
                    , row my_border
                        [ file_panel_left model
                        , file_panel_right model
                        ]
                    , el ([ Background.color (rgb 0.5 0.5 0.5) ] ++ my_border) (text "status")
                    ]
                )
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
            , paragraph [] [ text (Debug.toString model) ]
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


httpLoadFiles : Model -> Cmd Msg
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
        , expect = Http.expectJson LoadedFiles fileListDecoder
        }


fileListDecoder : Decoder Files
fileListDecoder =
    Decode.succeed Files
        |> required "pwd" string
        |> required "show_hidden" bool
        |> required "files" (list string)
