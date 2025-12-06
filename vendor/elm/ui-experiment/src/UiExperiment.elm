module UiExperiment exposing (CorrectedString, Dirs, FileObject, Files, Flags, Model)

import Browser
import Element exposing (Color, Element, alignTop, centerY, column, el, fill, height, htmlAttribute, inFront, layout, mouseDown, mouseOver, moveRight, padding, paragraph, px, rgb, rgb255, row, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes as HA
import Http
import Json.Decode as Decode exposing (Decoder, andThen, bool, int, list, string)
import Json.Decode.Pipeline exposing (hardcoded, required)
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


type alias CorrectedString =
    { original : String
    , corrected : Maybe String
    }


type alias Files =
    { pwd : CorrectedString
    , showHidden : Bool
    , files : List FileObject
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
    | Reload
    | LoadFiles
    | LoadedFiles (Result Http.Error Files)
    | LoadParent
    | LoadChild String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Toggle ->
            let
                model2 =
                    { model | toggle = not model.toggle }
            in
            update Reload model2

        LoadFiles ->
            ( model, httpLoadFiles model )

        LoadedFiles result ->
            case result of
                Ok fullText ->
                    ( { model
                        | dirs =
                            buildOnlyLeftDir { pwd = fullText.pwd, showHidden = fullText.showHidden, files = fullText.files }
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        LoadParent ->
            let
                m1fx =
                    model.dirs.leftDir
            in
            case m1fx of
                Nothing ->
                    ( model, Cmd.none )

                Just files ->
                    -- create new parent model
                    let
                        pwdx =
                            files.pwd.original

                        pwdxSplit =
                            String.split "/" pwdx

                        pwdxLen =
                            List.length pwdxSplit

                        pwdxStr =
                            pwdxSplit
                                |> List.take (pwdxLen - 1)
                                |> String.join "/"
                                |> String.append "/"

                        pwdxStrOk =
                            if String.slice 0 2 pwdxStr == "//" then
                                String.dropLeft 1 pwdxStr

                            else
                                pwdxStr

                        model2 =
                            { model
                                | dirs =
                                    buildOnlyLeftDir
                                        { pwd =
                                            { original = pwdxStrOk
                                            , corrected = Nothing
                                            }
                                        , showHidden = False
                                        , files = []
                                        }
                            }
                    in
                    ( model2, httpLoadFiles model2 )

        LoadChild child ->
            case model.dirs.leftDir of
                Nothing ->
                    ( model, Cmd.none )

                Just files ->
                    let
                        model2 =
                            { model
                                | dirs =
                                    buildOnlyLeftDir
                                        { pwd =
                                            { original =
                                                files.pwd.original ++ "/" ++ child
                                            , corrected = Nothing
                                            }
                                        , showHidden = model.toggle
                                        , files = []
                                        }
                            }
                    in
                    ( model2, httpLoadFiles model2 )

        Reload ->
            case model.dirs.leftDir of
                Nothing ->
                    ( model, Cmd.none )

                Just files ->
                    let
                        model2 =
                            { model
                                | dirs =
                                    buildOnlyLeftDir
                                        { pwd = files.pwd
                                        , showHidden = model.toggle
                                        , files = []
                                        }
                            }
                    in
                    ( model2, httpLoadFiles model2 )



-- ACTIONS


httpLoadFiles : Model -> Cmd Msg
httpLoadFiles model =
    let
        domain : String
        domain =
            "http://127.0.0.1:3000"

        path : String
        path =
            "/api/list-files"
    in
    Http.post
        { url = domain ++ path
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "pwd"
                      , case model.dirs.leftDir of
                            Nothing ->
                                Encode.string "/home/jacek"

                            Just files ->
                                Encode.string files.pwd.original
                      )
                    , ( "show_hidden", Encode.bool model.toggle )
                    ]
                )
        , expect = Http.expectJson LoadedFiles fileListDecoder
        }


buildOnlyLeftDir : Files -> Dirs
buildOnlyLeftDir dir =
    { leftDir = Just dir
    , rightDir = Nothing
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


my_border : List (Element.Attribute msg)
my_border =
    [ Border.width 1, Border.color color.blue ]


file_panel : Model -> String -> Element Msg
file_panel model lr =
    let
        lrdir =
            if lr == "left" then
                model.dirs.leftDir

            else
                model.dirs.rightDir
    in
    column
        (alignTop
            :: my_border
        )
        [ case lrdir of
            Nothing ->
                el ([ width fill, Background.color color.lightBlue ] ++ my_border) (text ("toolbar " ++ lr))

            Just files ->
                column [ width fill, Background.color color.yellow ]
                    [ el [] (text "parent button will go here")
                    , Input.button
                        [ padding 10
                        , Border.width 3
                        , Border.rounded 6
                        , Border.color color.blue
                        , Background.color color.lightBlue
                        , Font.variant Font.smallCaps
                        ]
                        { onPress = Just LoadParent, label = text "Parent" }
                    , el ([ width fill, Background.color color.lightBlue ] ++ my_border) (text files.pwd.original)
                    ]
        , case lrdir of
            Nothing ->
                el my_border (text "No files")

            Just files ->
                panel_files model files
        ]


file_panel_left : Model -> Element Msg
file_panel_left model =
    file_panel model "left"


file_panel_right : Model -> Element Msg
file_panel_right model =
    file_panel model "right"


panel_files : Model -> Files -> Element Msg
panel_files _ files =
    column []
        (List.map
            (\x ->
                let
                    isDirectory =
                        x.ftype == "directory"
                in
                if isDirectory then
                    Input.button
                        [ padding 1
                        , width fill
                        , Border.width 1
                        , Border.color color.blue
                        , Background.color color.lightBlue
                        ]
                        { onPress = Just (LoadChild x.name), label = text x.name }

                else
                    el
                        (if x.mtime == "" then
                            [ Background.color color.yellow ]

                         else
                            []
                        )
                        (text x.name)
            )
            files.files
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
                , label = Input.labelRight [] (text "Show Hidden")
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
                    (alignTop :: my_border)
                    [ el [] (text "general toolbar")
                    , row my_border
                        [ file_panel_left model
                        , file_panel_right model
                        ]
                    , el
                        ([ width fill
                         , Background.color (rgb 0.5 0.5 0.5)
                         ]
                            ++ my_border
                        )
                        (text "status")
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
    , yellow = rgb255 0xFF 0xEB 0x00
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



-- DECODERS


correctedStringDecoder : Decoder CorrectedString
correctedStringDecoder =
    string
        |> andThen
            (\cstr ->
                Decode.succeed CorrectedString
                    |> hardcoded cstr
                    |> hardcoded Nothing
            )


fileListDecoder : Decoder Files
fileListDecoder =
    Decode.succeed Files
        |> required "pwd" correctedStringDecoder
        |> required "show_hidden" bool
        |> required "files" (list fileDecoder)


fileDecoder : Decoder FileObject
fileDecoder =
    Decode.succeed FileObject
        |> required "name" string
        |> required "executable" bool
        |> required "extname" string
        |> required "ftype" string
        |> required "size" int
        |> required "mtime" string
        |> required "mode" int
        |> required "symlink" bool


type alias FileObject =
    { name : String
    , executable : Bool
    , extname : String
    , ftype : String
    , size : Int
    , mtime : String
    , mode : Int
    , symlink : Bool
    }
