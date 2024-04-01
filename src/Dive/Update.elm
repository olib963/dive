module Dive.Update exposing (Key(..), Msg(..), update)

import Dive.Model exposing (..)
import Time


type Msg
    = Forth
    | Back
    | Animate Time.Posix
    | Resize WindowSize
    | KeyPressed Key


type Key
    = ArrowLeft
    | ArrowRight


update : Msg -> Model -> Model
update msg model =
    case msg of
        Resize size ->
            resize size model

        Forth ->
            forth model

        Back ->
            back model

        KeyPressed ArrowLeft ->
            back model

        KeyPressed ArrowRight ->
            forth model

        Animate diff ->
            animate diff model
