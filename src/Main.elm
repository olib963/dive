module Main exposing (frames, init, main, world)

import Browser
import Dive exposing (..)
import Dive.ElmLogo exposing (logo)
import Dive.Model as Model


world =
    [ logo ( 0, 0 ) ( 1, 1 )
    , text ( 0, 0 ) "Hello Dive!"
        |> transformObject ( 0.001, 0.001 ) ( 0, 0 )
    ]


frames =
    [ frame ( 1, 1 ) ( 0, 0 )
    , frame ( 0.01, 0.01 ) ( 0, 0 )
        |> duration 2000
    ]


init size =
    ( Dive.init size
        |> Dive.world world
        |> Dive.frames frames
    , Cmd.none
    )


main : Program Model.WindowSize Model Msg
main =
    Browser.element
        { init = init
        , update = Dive.update
        , view = Dive.view
        , subscriptions =
            Dive.subscriptions
        }
