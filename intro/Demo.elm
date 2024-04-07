module Demo exposing (main)

import Browser
import Dive exposing (WindowSize)
import Dive.ElmLogo exposing (logo)
import Html
import Intro


init size =
    ( Dive.init size
        |> Dive.world Intro.world
        |> Dive.frames Intro.frames
    , Cmd.none
    )


main : Program WindowSize Dive.Model Dive.Msg
main =
    Browser.element
        { init = init
        , update = Dive.update
        , view = Dive.view
        , subscriptions = Dive.subscriptions
        }
