module View exposing (view)

import FinishPage
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy)
import IntroPage
import Model exposing (..)
import Ui
import Update exposing (Msg(..))


type StoryState
    = ShowCover
    | ShowRants
    | ShowVideo
    | ShowEvents


view : Model -> Html.Html Msg
view m =
    let
        content =
            case m.state of
                IntroPage ->
                    IntroPage.view Next

                ShowStory ->
                    viewStory (readStory m)

                FinishPage m ->
                    FinishPage.view m

        revealClass =
            case m.transition of
                FromLeft ->
                    "FromLeft"

                FromRight ->
                    "FromRight"

                FadeOut ->
                    "FadeOut"

                Reset ->
                    "ResetAnimation"
    in
    div [ class revealClass ] content
