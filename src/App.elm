module App exposing (main)

import Browser
import Browser.Events exposing (onAnimationFrameDelta, onKeyDown, onKeyUp, onResize)
import Html.Events exposing (keyCode)
import Http
import Json.Decode as Decode
import Json.Encode exposing (Value)
import Model exposing (Model, modelDecoder)
import Update exposing (Msg(..))
import View


main : Program Value Model Msg
main =
    Browser.element
        { init = \flags -> ( Model.init, getJsonRequest )
        , update = Update.update
        , subscriptions = subscriptions
        , view = View.view
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onKeyDown (Decode.map key keyCode) ]


key : Int -> Msg
key keycode =
    case keycode of
        37 ->
            Prev

        39 ->
            Next

        _ ->
            NoOp


getJsonRequest : Cmd Msg
getJsonRequest =
    Http.send FetchStories (Http.get "/static/data.json" modelDecoder)
