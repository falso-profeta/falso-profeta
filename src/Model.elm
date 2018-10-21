module Model exposing
    ( AppState(..)
    , Event
    , Model
    , Quote(..)
    , Rant
    , Source
    , Story
    , StoryState(..)
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
    | FinishPage


type StoryState
    = ShowCover
    | ShowRants
    | ShowVideo
    | ShowEvents


type alias Model =
    { stories : Tape Story
    , state : AppState
    }


modelDecoder : D.Decoder Model
modelDecoder =
    D.list storyDecoder
        |> D.andThen
            (\sts ->
                D.succeed
                    { stories = Tape.rewind <| Tape.fromList defaultStory (sts ++ sts)
                    , state = IntroPage
                    }
            )


type alias Story =
    { state : StoryState
    , bible : String
    , ref : String
    , utter : String
    , youtube : Url
    , image : Url
    , events : List Event
    , rants : List Rant
    }


storyDecoder : D.Decoder Story
storyDecoder =
    D.map7 (Story ShowCover)
        (D.field "bible" D.string)
        (D.field "ref" D.string)
        (D.field "utter" D.string)
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
    Model (Tape.single defaultStory) IntroPage


defaultStory : Story
defaultStory =
    { bible = "<default>"
    , ref = "<default>"
    , utter = "<default>"
    , youtube = ""
    , image = ""
    , events = []
    , rants = []
    , state = ShowCover
    }


readStory : Model -> Story
readStory m =
    read m.stories
