module Main exposing (main)

import Ink exposing (Ink)
import Ink.Style
import Time


main : Program () Model Msg
main =
    Ink.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { name : String
    , names : List String
    , num : Int
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( { name = ""
      , names = []
      , num = 0
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 (\_ -> Tick)


type Msg
    = GotName String
    | Tick


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotName name ->
            ( { model | names = name :: model.names }, Cmd.none )

        Tick ->
            ( { model | num = model.num + 1 }, Cmd.none )


view : Model -> { title : String, body : Ink Msg }
view model =
    { title = "Elm Ink!"
    , body =
        Ink.column
            [ Ink.Style.setBacgroundColor Ink.Style.Black
            , Ink.Style.setFontColor Ink.Style.Cyan
            , Ink.Style.Bold
            ]
            [ Ink.text [] "Hello!"
            , Ink.text
                [ Ink.Style.setBacgroundColor Ink.Style.Yellow
                , Ink.Style.setFontColor Ink.Style.Black
                , Ink.Style.Italic
                ]
                "Welcome to Elm Ink!"
            , Ink.text [] ""
            , Ink.text
                -- [ Ink.Style.setBacgroundColor Ink.Style.Yellow
                -- , Ink.Style.setFontColor Ink.Style.Black
                -- ]
                []
                "We're glad you could stop by :)"
            ]
    }
