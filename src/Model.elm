module Model exposing
    ( AppState(..)
    , Event
    , Model
    , Rant
    , Source
    , Story
    , StoryState(..)
    , TransitionState(..)
    , init
    , mapStory
    , modelDecoder
    , readStory
    )

import FinishPage
import Tape exposing (..)
import Types exposing (..)



--- MODEL ----------------------------------------------------------------------


type AppState
    = IntroPage
    | ShowStory
    | FinishPage FinishPage.Model


type alias Model =
    { stories : Tape Story
    , state : AppState
    , transition : TransitionState
    }


modelDecoder : D.Decoder Model
modelDecoder =
    let
        toModel sts =
            D.succeed { init | stories = tape sts }

        tape sts =
            Tape.rewind (Tape.fromList defaultStory sts)
    in
    D.list storyDecoder
        |> D.andThen toModel
