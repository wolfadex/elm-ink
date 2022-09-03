module Main exposing (main)

import Ink exposing (Ink)
import Ink.Style
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
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 2000 (\_ -> Tick)


type Msg
    = Tick


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


view : Model -> { title : String, body : Ink Msg }
view model =
    { title = "Elm Ink!"
    , body =
        Ink.column
            [ Ink.Style.Bold
            ]
            [ Ink.text
                [ Ink.Style.setBacgroundColor Ink.Style.Yellow
                , Ink.Style.setFontColor Ink.Style.Black
                , Ink.Style.Italic
                ]
                "Hello!"
            , Ink.row
                []
                [ Ink.text
                    []
                    "Welcome to "
                , Ink.text
                    [ Ink.Style.setBacgroundColor Ink.Style.Black
                    , Ink.Style.setFontColor Ink.Style.Cyan
                    ]
                    "Elm Ink"
                ]
            , Ink.text [] ""
            , Ink.text [] model.phrase
            ]
    }
