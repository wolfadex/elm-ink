port module Main exposing (main)

import Ink exposing (Ink)
import Ink.AnsiColor
import Ink.Border
import Ink.Font
import Random exposing (Seed)
import Time


main : Program Int Model Msg
main =
    Ink.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { phrase : String
    , seed : Seed
    , input : String
    }


phrases : ( String, List String )
phrases =
    ( "We're glad you could join us :)"
    , [ "Get ready for some fun!"
      , "An Elm package for TUIs"
      ]
    )


init : Int -> ( Model, Cmd Msg )
init initialSeed =
    let
        ( first, rest ) =
            phrases

        ( phrase, seed ) =
            Random.step
                (Random.uniform first rest)
                (Random.initialSeed initialSeed)
    in
    ( { phrase = phrase
      , seed = seed
      , input = ""
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Time.every 2000 (\_ -> Tick)
        , stdin Stdin
        ]


port stdin : (String -> msg) -> Sub msg


port logFile : String -> Cmd msg


type Msg
    = Tick
    | Stdin String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick ->
            let
                ( first, rest ) =
                    phrases

                ( phrase, seed ) =
                    Random.step
                        (Random.uniform first rest)
                        model.seed
            in
            ( { model
                | phrase = phrase
                , seed = seed
              }
            , Cmd.none
            )

        Stdin str ->
            ( { model
                | input =
                    -- Delete or Backspace (not sure about forward delete)
                    if str == "\u{007F}" || str == "\u{0008}" then
                        String.dropRight 1 model.input

                    else
                        model.input ++ str
              }
            , Cmd.none
            )


view : Model -> { title : String, body : Ink Msg }
view model =
    { title = "Elm Ink!"
    , body =
        Ink.column
            [ Ink.Font.bold
            ]
            [ Ink.text
                [ Ink.backgroundColor Ink.AnsiColor.yellow
                , Ink.Font.color Ink.AnsiColor.black
                , Ink.Font.italic
                ]
                "Hello!"
            , Ink.row
                []
                [ Ink.text
                    []
                    "Welcome to "
                , Ink.text
                    [ Ink.backgroundColor Ink.AnsiColor.black
                    , Ink.Font.color Ink.AnsiColor.cyan
                    , Ink.Font.underline
                    , Ink.Border.single
                    , Ink.Border.color Ink.AnsiColor.red
                    ]
                    "Elm Ink"
                ]
            , Ink.text [] ""
            , Ink.text
                [ Ink.Font.faint
                , Ink.Border.double
                , Ink.Border.backgroundColor Ink.AnsiColor.blue
                ]
                model.phrase
            , Ink.text
                []
                model.input
            ]
    }
