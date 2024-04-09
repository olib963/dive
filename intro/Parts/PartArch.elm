module Parts.PartArch exposing (frames, world)

import Color exposing (black, blue, red, white)
import Dive exposing (..)
import Params


archCode =
    """
main =
  Html.program
    { init = model
    , view = view
    , update = update
    , subscriptions =
        subscriptions
    }
"""


archText =
    text ( -5, 0 ) archCode
        |> color Color.darkRed
        |> fontFamily Params.fontCode
        |> height 1
        |> leftAligned
        |> lineHeight 1.3


world =
    archText


archFrame =
    frame ( 12, 12 ) ( 3, -6 ) |> duration 1000


frames =
    [ archFrame
    ]
