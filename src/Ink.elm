module Ink exposing (..)

import Browser
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Ink.Style exposing (Style)
import Json.Decode


program :
    { init : flags -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> { title : String, body : Ink msg }
    }
    -> Program flags model msg
program config =
    Browser.document
        { init = config.init
        , update = config.update
        , subscriptions = config.subscriptions
        , view = view config.view
        }


view : (model -> { title : String, body : Ink msg }) -> model -> Browser.Document msg
view userView model =
    let
        res =
            userView model
    in
    { title = res.title
    , body =
        [ inkToHtml res.body ]
    }


inkToHtml : Ink msg -> Html msg
inkToHtml ink =
    case ink of
        InkText str ->
            Html.text str

        InkInput onInput value ->
            inkNode "textinput"
                [ Html.Attributes.value value
                , Html.Events.on "submit" (Json.Decode.map onInput Json.Decode.string)
                ]
                []

        InkColumn styles children ->
            inkNode "column"
                (List.map Ink.Style.encode styles)
                (List.map inkToHtml children)

        InkRow styles children ->
            inkNode "row"
                (List.map Ink.Style.encode styles)
                (List.map inkToHtml children)

        InkElement styles child ->
            inkNode "element"
                (List.map Ink.Style.encode styles)
                [ inkToHtml child ]


inkNode : String -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
inkNode suffix =
    Html.node ("elm-ink-" ++ suffix)



---- UI PIECES ----


type Ink msg
    = InkText String
    | InkInput (String -> msg) String
    | InkColumn (List Style) (List (Ink msg))
    | InkElement (List Style) (Ink msg)
    | InkRow (List Style) (List (Ink msg))


text : String -> Ink msg
text =
    InkText


input : { onChange : String -> msg, value : String } -> Ink msg
input config =
    InkInput config.onChange config.value


column : List Style -> List (Ink msg) -> Ink msg
column =
    InkColumn


row : List Style -> List (Ink msg) -> Ink msg
row =
    InkRow
