module Ink.Font exposing (..)

import Html.Attributes
import Ink.AnsiColor exposing (AnsiColor, Location(..))
import Internal exposing (Style(..))


color : AnsiColor -> Style msg
color c =
    Style (Html.Attributes.attribute "elm-ink-font-color" (Ink.AnsiColor.encode Foreground c))


bold : Style msg
bold =
    Style (Html.Attributes.attribute "elm-ink-font-bold" "1")


faint : Style msg
faint =
    Style (Html.Attributes.attribute "elm-ink-font-faint" "2")


italic : Style msg
italic =
    Style (Html.Attributes.attribute "elm-ink-font-italic" "3")


underline : Style msg
underline =
    Style (Html.Attributes.attribute "elm-ink-font-underline" "4")
