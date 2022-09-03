module Ink.AnsiColor exposing
    ( AnsiColor
    , Location(..)
    , black
    , blue
    , cyan
    , encode
    , fromColor
    , green
    , magenta
    , red
    , toColor
    , white
    , yellow
    )

import Color exposing (Color)
import Internal exposing (AnsiColor(..))


type Location
    = Foreground
    | Background


fromColor : Color -> AnsiColor
fromColor c =
    let
        parts : { red : Float, green : Float, blue : Float, alpha : Float }
        parts =
            Color.toRgba c
    in
    AnsiColor
        { red = floatToInt parts.red
        , green = floatToInt parts.green
        , blue = floatToInt parts.blue
        }


floatToInt : Float -> Int
floatToInt f =
    ceiling (255 * f)


toColor : AnsiColor -> Color
toColor (AnsiColor c) =
    Color.fromRgba
        { red = intToFloat c.red
        , green = intToFloat c.green
        , blue = intToFloat c.blue
        , alpha = 1
        }


intToFloat : Int -> Float
intToFloat i =
    toFloat i / 255


type alias AnsiColor =
    Internal.AnsiColor


encode : Location -> AnsiColor -> String
encode location (AnsiColor col) =
    [ encodeLocation location, 2, col.red, col.green, col.blue ]
        |> List.map String.fromInt
        |> String.join ";"


encodeLocation : Location -> Int
encodeLocation loc =
    case loc of
        Foreground ->
            38

        Background ->
            48


black : AnsiColor
black =
    AnsiColor { red = 0, green = 0, blue = 0 }


red : AnsiColor
red =
    AnsiColor { red = 255, green = 0, blue = 0 }


green : AnsiColor
green =
    AnsiColor { red = 0, green = 255, blue = 0 }


yellow : AnsiColor
yellow =
    AnsiColor { red = 255, green = 255, blue = 0 }


blue : AnsiColor
blue =
    AnsiColor { red = 0, green = 0, blue = 255 }


magenta : AnsiColor
magenta =
    AnsiColor { red = 255, green = 0, blue = 255 }


cyan : AnsiColor
cyan =
    AnsiColor { red = 0, green = 255, blue = 255 }


white : AnsiColor
white =
    AnsiColor { red = 255, green = 255, blue = 255 }


{-| Specify the amount of red, green, and blue in the range of 0 - 255
-}
rgb : { red : Int, green : Int, blue : Int } -> AnsiColor
rgb opts =
    AnsiColor { red = opts.red, blue = opts.blue, green = opts.green }
