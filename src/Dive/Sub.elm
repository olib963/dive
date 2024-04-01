module Dive.Sub exposing (subscriptions)

import Browser.Events
import Dive.Model exposing (..)
import Dive.Update exposing (Key(..), Msg(..))
import Json.Decode as D


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onResize (\w h -> Resize { width = w, height = h })
        , case model.animation of
            Nothing ->
                Sub.none

            Just _ ->
                Browser.Events.onAnimationFrame Animate
        , Browser.Events.onClick (D.succeed Forth)
        , Browser.Events.onKeyDown keyDecoder
        ]


keyDecoder : D.Decoder Msg
keyDecoder =
    D.string |> D.field "key" |> D.andThen toValidKey |> D.map KeyPressed


toValidKey : String -> D.Decoder Key
toValidKey s =
    case s of
        "ArrowLeft" ->
            D.succeed ArrowLeft

        "ArrowRight" ->
            D.succeed ArrowRight

        _ ->
            D.fail <| "Invalid key: " ++ s
