module App exposing (main, mainWrapper)

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
    mainWrapper View.view


mainWrapper view =
    Browser.element
        { init = \_ -> ( Model.init, getJsonRequest )
        , update = Update.update
        , subscriptions = subscriptions
        , view = view
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
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
    Http.get
        { url = "./static/data.json"
        , expect = Http.expectJson FetchStories modelDecoder
        }
