module Update exposing (Msg(..), update)

import Http
import Model
    exposing
        ( AppState(..)
        , Model
        , Story
        , StoryState(..)
        , mapStory
        , readStory
        , TransitionState(..)
        )
import Process
import Tape exposing (..)
import Task


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
            (advance m, Cmd.none )
        
        Prev ->
            (back m, Cmd.none )

        ToggleRants ->
            (mapStory (toggleStoryState ShowCover ShowRants) m, Cmd.none )

        ToggleVideo ->
            (mapStory (toggleStoryState ShowCover ShowVideo) m, Cmd.none )

        ToggleEvents ->
            (mapStory (toggleStoryState ShowCover ShowEvents) m, Cmd.none )

        ToggleLinks ->
            (toggleState (FinishPage True) (FinishPage False) m, Cmd.none )

        FetchStories (Ok model) ->
            ({ m | stories = model.stories }, Cmd.none )

        FetchStories (Err e) ->
            (m, Cmd.none)

        Restart ->
            ({ m | state = IntroPage }, Cmd.none )

        Transition pre post nextMsg ->
            case (pre, post) of
                (Nothing, Nothing) ->
                    (m, Cmd.none)
                (Nothing, Just step) ->
                    let
                        (new, _) = update nextMsg m
                        task = Task.perform (\_ -> Transition Nothing Nothing nextMsg) (Process.sleep (duration step))
                    in
                    ({ new | transition = step }, task)
                (Just step, _) -> 
                    let 
                        task = Task.perform (\_ -> Transition Nothing post nextMsg) (Process.sleep (duration step)) 
                    in 
                    ( { m | transition = step }, task )

        _ ->
            (m, Cmd.none )

duration : TransitionState -> Float
duration step = 
    case step of
        FadeOut -> 150
        Reset -> 1
        FromLeft -> 250
        FromRight -> 250


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
            { m | state = ShowStory, stories = m.stories |> resetStoryState  |> rewind }


resetStoryState : Tape Story -> Tape Story
resetStoryState tape =
    mapHead (\st -> { st | state = ShowCover }) tape
