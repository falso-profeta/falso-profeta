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
        )
import Tape exposing (..)


type Msg
    = Next
    | Prev
    | NoOp
    | ToggleRants
    | ToggleVideo
    | ToggleEvents
    | FetchStories (Result Http.Error Model)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg m =
    ( updateModel msg m, Cmd.none )


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
            mapStory (toggleStoryState ShowRants ShowVideo) m

        ToggleEvents ->
            mapStory (toggleStoryState ShowCover ShowEvents) m

        FetchStories (Ok model) ->
            { m | stories = model.stories }

        FetchStories (Err _) ->
            m

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
