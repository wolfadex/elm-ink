module Ink.Style exposing (..)

import Html
import Html.Attributes


type Style
    = Color Location AnsiColor


type Location
    = Foreground
    | Background


type AnsiColor
    = Black
    | Red
    | Green
    | Yellow
    | Blue
    | Magenta
    | Cyan
    | White
    | Specific RGB


type alias RGB =
    { red : Int
    , green : Int
    , blue : Int
    }


encode : Style -> Html.Attribute msg
encode style =
    case style of
        Color location color ->
            Html.Attributes.attribute ("style-" ++ locationName location) ("\u{001B}[" ++ encodeColor color (encodeLocation location) ++ "m")


locationName : Location -> String
locationName loc =
    case loc of
        Foreground ->
            "foreground"

        Background ->
            "background"


encodeLocation : Location -> Int
encodeLocation loc =
    case loc of
        Foreground ->
            0

        Background ->
            10


encodeColor : AnsiColor -> Int -> String
encodeColor color loc =
    case color of
        Black ->
            String.fromInt (30 + loc)

        Red ->
            String.fromInt (31 + loc)

        Green ->
            String.fromInt (32 + loc)

        Yellow ->
            String.fromInt (33 + loc)

        Blue ->
            String.fromInt (34 + loc)

        Magenta ->
            String.fromInt (35 + loc)

        Cyan ->
            String.fromInt (36 + loc)

        White ->
            String.fromInt (37 + loc)

        Specific col ->
            String.fromInt (38 + loc)
                ++ ([ col.red, col.green, col.blue ]
                        |> List.map String.fromInt
                        |> String.join ";"
                   )


setFontColor : AnsiColor -> Style
setFontColor color =
    Color Foreground color


setBacgroundColor : AnsiColor -> Style
setBacgroundColor color =
    Color Background color


rgb : { red : Int, green : Int, blue : Int } -> AnsiColor
rgb opts =
    Specific { red = opts.red, blue = opts.blue, green = opts.green }
