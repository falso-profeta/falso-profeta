module Update exposing (Msg(..), update)

import Http
import Model
    exposing
        ( AppState(..)
        , Model
        , Story
        , StoryState(..)
        , TransitionState(..)
        , mapStory
        , readStory
        )
import Process
import Task
import Tape exposing (..)


type Msg
    = Next
    | Prev
    | NoOp
    | ToggleRants
    | ToggleVideo
    | ToggleEvents
    | ToggleLinks
    | Restart
    | FetchStories (Result Http.Error Model)
    | Transition (Maybe TransitionState) (Maybe TransitionState) Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg m =
    case msg of
        Next ->
            ( advance m, Cmd.none )

        Prev ->
            ( back m, Cmd.none )

        _ ->
            ( m, Cmd.none )




toggleState : AppState -> AppState -> Model -> Model
toggleState a b m =
    let
        state =
            if m.state == a then
                b

            else if m.state == b then
                a

            else
                m.state
    in
    { m | state = state }


toggleStoryState : StoryState -> StoryState -> Story -> Story
toggleStoryState a b st =
    if st.state == b then
        { st | state = a }

    else
        { st | state = b }


advance : Model -> Model
advance m =
    case m.state of
        IntroPage ->
            { m
                | state = ShowStory
                , stories = resetStoryState m.stories
            }

        ShowStory ->
            case popRight m.stories of
                ( Just y, tape ) ->
                    { m | stories = resetStoryState tape }

                ( Nothing, tape ) ->
                    { m | state = FinishPage False }

        FinishPage bool ->
            { m
                | state = IntroPage
                , stories = resetStoryState (rewind m.stories)
            }


back : Model -> Model
back m =
    case m.state of
        IntroPage ->
            { m | state = FinishPage False }

        ShowStory ->
            case popLeft m.stories of
                ( Just y, tape ) ->
                    { m | stories = resetStoryState tape }

                ( Nothing, tape ) ->
                    { m | state = IntroPage }

        FinishPage _ ->
            { m | state = ShowStory, stories = m.stories |> resetStoryState |> rewind }


resetStoryState : Tape Story -> Tape Story
resetStoryState tape =
    mapHead (\st -> { st | state = ShowCover }) tape
