module AppProduction exposing (main)

import App
import Json.Encode exposing (Value)
import Model exposing (Model)
import Update exposing (Msg(..))
import View


main : Program Value Model Msg
main =
    App.mainWrapper (\m -> View.viewWrapper [] m)
