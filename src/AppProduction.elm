module AppProduction exposing (main)

import App
import View
import Model exposing (Model)
import Update exposing (Msg(..))
import Json.Encode exposing (Value)


main : Program Value Model Msg
main =
    App.mainWrapper (\m -> View.viewWrapper [] m)
