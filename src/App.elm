module App exposing (main)

import Json.Encode exposing (Value)
import Main
import Model exposing (Model)
import Update exposing (Msg(..))
import View


main : Program Value Model Msg
main =
    Main.mainWrapper (\m -> View.viewWrapper [] m)
