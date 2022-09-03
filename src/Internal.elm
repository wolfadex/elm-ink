module Internal exposing (..)


type AnsiColor
    = AnsiColor RGB


type alias RGB =
    { red : Int
    , green : Int
    , blue : Int
    }
