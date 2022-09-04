module Ink.Border exposing
    ( single
    , double
    , backgroundColor, bold, classic, color, custom, doubleSingle, rounded, singleDouble
    )

{-| Styles borrowed from <https://www.npmjs.com/package/cli-boxes>

@docs single
@docs double

-}

import Html.Attributes
import Ink.AnsiColor exposing (Location(..))
import Internal exposing (AnsiColor, Style(..))
import Json.Encode


{-| A thin box with sharp corners

┌────┐
│ sl │
└────┘

-}
single : Style msg
single =
    encode
        [ ( "topLeft", "┌" )
        , ( "top", "─" )
        , ( "topRight", "┐" )
        , ( "right", "│" )
        , ( "bottomRight", "┘" )
        , ( "bottom", "─" )
        , ( "bottomLeft", "└" )
        , ( "left", "│" )
        ]


{-| 2 thin, nested boxes with sharp corners

╔════╗
║ db ║
╚════╝

-}
double : Style msg
double =
    encode
        [ ( "topLeft", "╔" )
        , ( "top", "═" )
        , ( "topRight", "╗" )
        , ( "right", "║" )
        , ( "bottomRight", "╝" )
        , ( "bottom", "═" )
        , ( "bottomLeft", "╚" )
        , ( "left", "║" )
        ]


{-| A thin box with rounded corners

╭────╮
│ rd │
╰────╯

-}
rounded : Style msg
rounded =
    encode
        [ ( "topLeft", "╭" )
        , ( "top", "─" )
        , ( "topRight", "╮" )
        , ( "right", "│" )
        , ( "bottomRight", "╯" )
        , ( "bottom", "─" )
        , ( "bottomLeft", "╰" )
        , ( "left", "│" )
        ]


{-| A thick box with sharp corners

┏━━━━┓
┃ bd ┃
┗━━━━┛

-}
bold : Style msg
bold =
    encode
        [ ( "topLeft", "┏" )
        , ( "top", "━" )
        , ( "topRight", "┓" )
        , ( "right", "┃" )
        , ( "bottomRight", "┛" )
        , ( "bottom", "━" )
        , ( "bottomLeft", "┗" )
        , ( "left", "┃" )
        ]


{-| A box with sharp corners, thin on the top and bottom and doubled up on the sides

╓────╖
║ sd ║
╙────╜

-}
singleDouble : Style msg
singleDouble =
    encode
        [ ( "topLeft", "╓" )
        , ( "top", "─" )
        , ( "topRight", "╖" )
        , ( "right", "║" )
        , ( "bottomRight", "╜" )
        , ( "bottom", "─" )
        , ( "bottomLeft", "╙" )
        , ( "left", "║" )
        ]


{-| A box with sharp corners, thin on the sides and doubled on top and bottom

╒════╕
│ ds │
╘════╛

-}
doubleSingle : Style msg
doubleSingle =
    encode
        [ ( "topLeft", "╒" )
        , ( "top", "═" )
        , ( "topRight", "╕" )
        , ( "right", "│" )
        , ( "bottomRight", "╛" )
        , ( "bottom", "═" )
        , ( "bottomLeft", "╘" )
        , ( "left", "│" )
        ]


{-| A thin box with plus shaped corners

+----+
| cs |
+----+

-}
classic : Style msg
classic =
    encode
        [ ( "topLeft", "+" )
        , ( "top", "-" )
        , ( "topRight", "+" )
        , ( "right", "|" )
        , ( "bottomRight", "+" )
        , ( "bottom", "-" )
        , ( "bottomLeft", "+" )
        , ( "left", "|" )
        ]


{-| Design your own box, suash as

•————•
∫ cm ∫
•————•

TODO: This may cause issues

-}
custom :
    { topLeft : Char
    , top : Char
    , topRight : Char
    , right : Char
    , bottomRight : Char
    , bottom : Char
    , bottomLeft : Char
    , left : Char
    }
    -> Style msg
custom options =
    encode
        [ ( "topLeft", String.fromChar options.topLeft )
        , ( "top", String.fromChar options.top )
        , ( "topRight", String.fromChar options.topRight )
        , ( "right", String.fromChar options.right )
        , ( "bottomRight", String.fromChar options.bottomRight )
        , ( "bottom", String.fromChar options.bottom )
        , ( "bottomLeft", String.fromChar options.bottomLeft )
        , ( "left", String.fromChar options.left )
        ]


color : AnsiColor -> Style msg
color c =
    Style (Html.Attributes.attribute "elm-ink-border-color" (Ink.AnsiColor.encode Foreground c))


backgroundColor : AnsiColor -> Style msg
backgroundColor c =
    Style (Html.Attributes.attribute "elm-ink-border-background-color" (Ink.AnsiColor.encode Foreground c))



---- INTERNAL ----


encode : List ( String, String ) -> Style msg
encode =
    List.map (Tuple.mapSecond Json.Encode.string)
        >> Json.Encode.object
        >> Html.Attributes.property "elmInkBorderFormat"
        >> Style
