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
        InkText styles str ->
            inkNode "text-container"
                [ Html.Attributes.attribute "font" (Ink.Style.encode styles)
                , Html.Attributes.attribute "text" str
                ]
                []

        InkInput onInput value ->
            inkNode "textinput"
                [ Html.Attributes.value value
                , Html.Events.on "submit" (Json.Decode.map onInput Json.Decode.string)
                ]
                []

        InkColumn styles children ->
            inkNode "column"
                [ Html.Attributes.attribute "font" (Ink.Style.encode styles)
                ]
                (List.map inkToHtml children)

        InkRow children ->
            inkNode "row"
                []
                (List.map inkToHtml children)

        InkElement child ->
            inkNode "element"
                []
                [ inkToHtml child ]


inkNode : String -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
inkNode suffix =
    Html.node ("elm-ink-" ++ suffix)



---- UI PIECES ----


type Ink msg
    = InkText (List Style) String
    | InkInput (String -> msg) String
    | InkColumn (List Style) (List (Ink msg))
    | InkElement (Ink msg)
    | InkRow (List (Ink msg))


text : List Style -> String -> Ink msg
text =
    InkText


input : { onChange : String -> msg, value : String } -> Ink msg
input config =
    InkInput config.onChange config.value


column : List Style -> List (Ink msg) -> Ink msg
column =
    InkColumn


row : List (Ink msg) -> Ink msg
row =
    InkRow
