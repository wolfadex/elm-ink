module Ink.Style exposing (..)

import Html


type BorderFormat
    = Single
    | Double
    | Round
    | BoldBorder
    | SingleDouble
    | DoubleSingle
    | Classic
    | Arrow
    | NoBorder


type Style msg
    = Style (Html.Attribute msg)
