module Dive.View exposing (view)

import Collage as C
import Collage.Render
import Collage.Text as T
import Dive.Model exposing (..)
import Dive.Update exposing (Msg(..))
import Ease
import Html exposing (Html)
import List.Extra


view : Model -> Html Msg
view model =
    model.world
        |> List.map object2Form
        |> C.group
        |> applyTransform (transform model)
        |> Collage.Render.svgBox ( model.viewport.width, model.viewport.height )


type alias Transform msg =
    List (C.Collage msg -> C.Collage msg)


applyTransform : Transform msg -> C.Collage msg -> C.Collage msg
applyTransform transforms collage =
    List.foldl (<|) collage transforms


transform : Model -> Transform msg
transform model =
    let
        current =
            case model.animation of
                Nothing ->
                    model.frames.current

                Just animation ->
                    animate animation.passed model.frames.current animation.target

        currentToViewport =
            { current
                | size = adaptWindowSize model.viewport current.size
            }
    in
    matrix model.viewport currentToViewport


matrix : Size -> Frame -> Transform msg
matrix viewport frame =
    let
        scale side v window =
            side v / side window

        scaleX =
            scale .width viewport frame.size

        scaleY =
            scale .height viewport frame.size

        translateX =
            negate <| frame.position.x * scaleX

        -- current.size.width / 2
        translateY =
            negate <| frame.position.y * scaleY

        -- current.size.height / 2
    in
    [ C.scaleX scaleX
    , C.scaleY scaleY
    , C.shift ( translateX, translateY )
    ]


adaptWindowSize : Size -> Size -> Size
adaptWindowSize viewportSize windowSize =
    let
        viewportRatio =
            viewportSize.width / viewportSize.height

        windowRatio =
            windowSize.width / windowSize.height
    in
    if windowRatio < viewportRatio then
        { windowSize
            | width = windowSize.height * viewportRatio
        }

    else
        { windowSize
            | height = windowSize.width / viewportRatio
        }


animate : Float -> Frame -> Frame -> Frame
animate passed oldframe frame =
    { frame
        | size = animateSize passed oldframe.size frame.size
        , position = animatePosition passed oldframe.position frame.position
    }


animateSize : Float -> Size -> Size -> Size
animateSize passed oldsize size =
    { size
        | width = animateX passed oldsize.width size.width
        , height = animateX passed oldsize.height size.height
    }


animatePosition : Float -> Position -> Position -> Position
animatePosition passed oldposition position =
    { position
        | x = animateX passed oldposition.x position.x
        , y = animateX passed oldposition.y position.y
    }


animateX : Float -> Float -> Float -> Float
animateX passed old int =
    (+) old <|
        (*) (Ease.inOutQuad passed) <|
            int
                - old


object2Form : Object -> C.Collage msg
object2Form object =
    case object of
        Text t ->
            C.group <|
                List.indexedMap (line t) <|
                    String.split "\n" t.text

        Polygon { gons, fill } ->
            C.polygon gons
                |> C.filled (C.uniform fill)

        Rectangle { border, fill, size, position } ->
            [ C.rectangle size.width size.height
                |> C.filled (C.uniform fill)
            , C.rectangle size.width size.height
                |> C.outlined border
            ]
                |> C.group
                |> C.shift ( position.x, position.y )

        Path { lineStyle, path } ->
            C.path path
                |> C.traced lineStyle

        Image { src, size, position } ->
            scalableImage C.image size src
                |> C.shift ( position.x, position.y )

        FittedImage { src, size, position } ->
            scalableImage fittedImage size src
                |> C.shift ( position.x, position.y )

        TiledImage { src, size, position } ->
            scalableImage tiledImage size src
                |> C.shift ( position.x, position.y )

        CroppedImage { src, size, offset, position } ->
            scalableCroppedImage offset size src
                |> C.shift ( position.x, position.y )

        Group objects ->
            C.group <|
                List.map object2Form objects


{-| TODO used to be E.fittedImage, how do we recreate this?
-}
fittedImage : ( Float, Float ) -> String -> C.Collage msg
fittedImage =
    C.image


{-| TODO used to be E.tiledImage, how do we recreate this?
-}
tiledImage : ( Float, Float ) -> String -> C.Collage msg
tiledImage =
    C.image


{-| TODO used to be E.croppedImage, how do we recreate this?
-}
croppedImage : ( Float, Float ) -> ( Float, Float ) -> String -> C.Collage msg
croppedImage ( x, y ) dims src =
    C.image dims src


rescaleImage : Float -> Float -> ( Float, Float, Float )
rescaleImage width height =
    let
        r =
            width / height

        w =
            1000.0

        h =
            w / r

        scale =
            width / w
    in
    ( w, h, scale )


scalableImage : (( Float, Float ) -> String -> C.Collage msg) -> Size -> String -> C.Collage msg
scalableImage image size src =
    let
        ( w, h, scale ) =
            rescaleImage size.width size.height
    in
    image ( w, h ) src
        |> C.scale scale


scalableCroppedImage : Position -> Size -> String -> C.Collage msg
scalableCroppedImage offset size src =
    let
        ( w, h, scale ) =
            rescaleImage size.width size.height

        ( oX, oY, _ ) =
            rescaleImage offset.x offset.y
    in
    croppedImage ( oX, oY ) ( w, h ) src
        |> C.scale scale


line : TextObject -> Int -> String -> C.Collage msg
line { color, fontFamily, height, align, lineHeight, position } i lineText =
    -- TODO text in the TextObject is unused. Is this intentional?
    let
        textFactor =
            100

        text_ =
            T.fromString lineText
                |> T.color color
                |> T.typeface (oldFontFaceToTextTypeface fontFamily)
                |> T.size textFactor

        shift =
            case align of
                Center ->
                    0

                Right ->
                    negate <| width / 2

                Left ->
                    width / 2

        element =
            text_

        -- TODO broken
        -- |> E.leftAligned
        width =
            element
                |> T.width
                |> (*) (height / textFactor)

        height_ =
            height / 2

        -- for some odd reason height is half the size
    in
    text_
        |> C.rendered
        |> C.scale (height / textFactor)
        |> C.shift
            ( position.x + shift
            , position.y + height_ / 2 - (toFloat i * (height * lineHeight))
            )


{-| A hacky little function to try and turn the generic List String representation of a font in to a Text Typeface
-}
oldFontFaceToTextTypeface : List String -> T.Typeface
oldFontFaceToTextTypeface fontFamily =
    case fontFamily of
        [ "serif" ] ->
            T.Serif

        [ "sans-serif" ] ->
            T.Sansserif

        [ "monospace" ] ->
            T.Monospace

        _ ->
            -- Don't know if this is right
            let
                fontStrings =
                    fontFamily
                        |> List.reverse
                        |> List.Extra.uncons
            in
            case fontStrings of
                Just ( fontStyle, fontNames ) ->
                    fontNames
                        |> List.map (\x -> "\"" ++ x ++ "\"")
                        |> (::) fontStyle
                        |> List.reverse
                        |> String.join ", "
                        |> T.Font

                Nothing ->
                    -- Default to sans-serif
                    T.Sansserif
