module Internal exposing (..)

import Html

type AnsiColor
    = AnsiColor RGB


type alias RGB =
    { red : Int
    , green : Int
    , blue : Int
    }

type Style msg
    = Style (Html.Attribute msg)