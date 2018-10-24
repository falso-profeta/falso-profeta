module Update exposing (Msg(..), update)

import Http
import Model
    exposing
        ( AppState(..)
        , Model
        , PageTransition(..)
        , Story
        , StoryState(..)
        , mapStory
        , readStory
        )
import Tape exposing (..)
import Task
import Time
import Process


type Msg
    = Next
    | Prev
    | NoOp
    | ToggleRants
    | ToggleVideo
    | ToggleEvents
    | FetchStories (Result Http.Error Model)
    | SetTransition PageTransition


update : Msg -> Model -> ( Model, Cmd Msg )
update msg m =
    let
        new =
            updateModel msg m
    in
    case msg of
        Next ->
            clearTransition FromLeft new

        Prev ->
            clearTransition FromRight new

        _ ->
            ( new, Cmd.none )


setTransition : PageTransition -> Cmd Msg
setTransition tr =
    Task.perform (\_ -> SetTransition tr) (Process.sleep 0)


clearTransition : PageTransition -> Model -> ( Model, Cmd Msg )
clearTransition tr m =
    ( { m | transition = ClearTransition }, setTransition tr )


updateModel : Msg -> Model -> Model
updateModel msg m =
    case msg of
        Next ->
            advance m

        Prev ->
            back m

        ToggleRants ->
            mapStory (toggleStoryState ShowCover ShowRants) m

        ToggleVideo ->
            mapStory (toggleStoryState ShowCover ShowVideo) m

        ToggleEvents ->
            mapStory (toggleStoryState ShowCover ShowEvents) m

        FetchStories (Ok model) ->
            { m | stories = model.stories }

        FetchStories (Err e) ->
            m
            -- Tuple.second (Debug.log "Decode error" e, m)

        SetTransition tr ->
            { m | transition = tr }

        NoOp ->
            m


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
                    { m | state = FinishPage }

        FinishPage ->
            { m
                | state = IntroPage
                , stories = resetStoryState (rewind m.stories)
            }


back : Model -> Model
back m =
    case m.state of
        IntroPage ->
            { m | state = FinishPage }

        ShowStory ->
            case popLeft m.stories of
                ( Just y, tape ) ->
                    { m | stories = resetStoryState tape }

                ( Nothing, tape ) ->
                    { m | state = IntroPage }

        FinishPage ->
            { m | state = ShowStory, stories = resetStoryState m.stories }


resetStoryState : Tape Story -> Tape Story
resetStoryState tape =
    mapHead (\st -> { st | state = ShowCover }) tape
