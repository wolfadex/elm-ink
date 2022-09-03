module Ink.Style exposing (..)


type Style
    = Color Location AnsiColor
    | Bold
    | Italic


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


encode : List Style -> String
encode styles =
    case styles of
        [] ->
            ""

        _ ->
            "\u{001B}[" ++ String.join ";" (List.map encodeStyle styles) ++ "m"


encodeStyle : Style -> String
encodeStyle style =
    case style of
        Color location color ->
            (encodeLocation location :: encodeColor color)
                |> List.map String.fromInt
                |> String.join ";"

        Bold ->
            "1"

        Italic ->
            "3"


encodeLocation : Location -> Int
encodeLocation loc =
    case loc of
        Foreground ->
            38

        Background ->
            48


encodeColor : AnsiColor -> List Int
encodeColor color =
    case color of
        Black ->
            [ 2, 0, 0, 0 ]

        Red ->
            [ 2, 255, 0, 0 ]

        Green ->
            [ 2, 0, 255, 0 ]

        Yellow ->
            [ 2, 255, 255, 0 ]

        Blue ->
            [ 2, 0, 0, 255 ]

        Magenta ->
            [ 2, 255, 0, 255 ]

        Cyan ->
            [ 2, 0, 255, 255 ]

        White ->
            [ 2, 255, 255, 255 ]

        Specific col ->
            [ 2, col.red, col.green, col.blue ]


setFontColor : AnsiColor -> Style
setFontColor color =
    Color Foreground color


setBacgroundColor : AnsiColor -> Style
setBacgroundColor color =
    Color Background color


rgb : { red : Int, green : Int, blue : Int } -> AnsiColor
rgb opts =
    Specific { red = opts.red, blue = opts.blue, green = opts.green }
