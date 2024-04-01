module Dive.ElmLogo exposing (logo)

{-| lba

@docs logo

-}

import Color
import Dive exposing (..)


{-| The Elm logo as an `Object` (essentially a `group` of `polygon`s). Gets a position and a size tuple as arguments.
-}
logo : ( Float, Float ) -> ( Float, Float ) -> Object
logo ( x, y ) ( w, h ) =
    [ polygon
        [ ( 0.01, 0.0 )
        , ( 0.99, 0.0 )
        , ( 0.5, 0.49 )
        ]
        |> fill Color.lightBlue
    , polygon
        [ ( 0.0, 0.01 )
        , ( 0.0, 0.99 )
        , ( 0.49, 0.5 )
        ]
        |> fill Color.darkBlue
    , polygon
        [ ( 1.0, 0.01 )
        , ( 1.0, 0.49 )
        , ( 0.76, 0.25 )
        ]
        |> fill Color.orange
    , polygon
        [ ( 0.51, 0.5 )
        , ( 0.75, 0.74 )
        , ( 0.99, 0.5 )
        , ( 0.75, 0.26 )
        ]
        |> fill Color.green
    , polygon
        [ ( 0.5, 0.51 )
        , ( 0.74, 0.75 )
        , ( 0.26, 0.75 )
        ]
        |> fill Color.orange
    , polygon
        [ ( 0.01, 1.0 )
        , ( 0.49, 1.0 )
        , ( 0.73, 0.76 )
        , ( 0.25, 0.76 )
        ]
        |> fill Color.green
    , polygon
        [ ( 0.51, 1.0 )
        , ( 1.0, 1.0 )
        , ( 1.0, 0.51 )
        ]
        |> fill Color.lightBlue
    ]
        |> group
        |> transformObject ( 1, 1 ) ( -0.5, -0.5 )
        |> transformObject ( w, h ) ( x, y )
