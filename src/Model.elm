module Model exposing
    ( AppState(..)
    , Event
    , Model
    , Quote(..)
    , Rant
    , Source
    , Story
    , StoryState(..)
    , TransitionState(..)
    , Url
    , init
    , mapStory
    , modelDecoder
    , readStory
    )

import Json.Decode as D
import Tape exposing (..)


type alias Url =
    String


type Quote
    = Quote String String



--- MODEL ----------------------------------------------------------------------


type AppState
    = IntroPage
    | ShowStory
    | FinishPage Bool

type StoryState
    = ShowCover
    | ShowRants
    | ShowVideo
    | ShowEvents

type TransitionState
    = FadeOut
    | FromLeft
    | FromRight
    | Reset

type alias Model =
    { stories : Tape Story
    , state : AppState
    , transition : TransitionState
    }


modelDecoder : D.Decoder Model
modelDecoder =
    let
        toModel sts =
            D.succeed
                { init
                    | stories =
                        Tape.rewind
                            (Tape.fromList defaultStory sts)
                }
    in
    D.list storyDecoder
        |> D.andThen toModel


type alias Story =
    { state : StoryState
    , bible : String
    , ref : String
    , utter : String
    , context : String
    , youtube : Url
    , image : Url
    , events : List Event
    , rants : List Rant
    }


storyDecoder : D.Decoder Story
storyDecoder =
    D.map8 (Story ShowCover)
        (D.field "bible" D.string)
        (D.field "ref" D.string)
        (D.field "utter" D.string)
        (D.field "context" D.string)
        (D.field "youtube" D.string)
        (D.field "image" D.string)
        (D.field "events" (D.list eventDecoder))
        (D.field "rants" (D.list rantDecoder))


type alias Event =
    { title : String
    , text : String
    , source : Source
    , image : Url
    }


eventDecoder : D.Decoder Event
eventDecoder =
    D.map4 Event
        (D.field "title" D.string)
        (D.field "text" D.string)
        (D.field "source" sourceDecoder)
        (D.field "image" D.string)


type alias Rant =
    { text : String
    , source : Maybe Source
    }


rantDecoder : D.Decoder Rant
rantDecoder =
    D.map2 Rant
        (D.field "text" D.string)
        (D.field "source" (D.maybe sourceDecoder))


type alias Source =
    { name : String
    , url : Url
    }


sourceDecoder : D.Decoder Source
sourceDecoder =
    D.map2 Source
        (D.field "name" D.string)
        (D.field "url" D.string)



--- UPDATE STORY


mapStory : (Story -> Story) -> Model -> Model
mapStory f m =
    { m | stories = mapHead f m.stories }



--- INITIAL MODELS


init : Model
init =
    Model (Tape.single defaultStory) IntroPage Reset


defaultStory : Story
defaultStory =
    { bible = "<default>"
    , ref = "<default>"
    , utter = "<default>"
    , context = "Bolsonaro, Deputado Federal"
    , youtube = ""
    , image = ""
    , events = []
    , rants = []
    , state = ShowCover
    }


readStory : Model -> Story
readStory m =
    read m.stories
