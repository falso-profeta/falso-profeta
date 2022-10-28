module Story exposing (..)

import Json.Decode as D
import Json.Decode.Pipeline exposing (hardcoded, required)


type alias Url =
    String


type alias Story =
    { name : String
    , bible : String
    , ref : String
    , utter : String
    , context : String
    , youtube : Url
    , image : Url
    , events : List Event
    , rants : List Rant
    }


type alias Event =
    { title : String
    , text : String
    , source : Source
    , image : Url
    }


type alias Rant =
    { text : String
    , source : Maybe Source
    }


type alias Source =
    { name : String
    , url : Url
    }



--- JSON Decoders -------------------------------------------------------------


storyDecoder : D.Decoder Story
storyDecoder =
    D.succeed Story
        |> required "name" D.string
        |> required "bible" D.string
        |> required "ref" D.string
        |> required "utter" D.string
        |> required "context" D.string
        |> required "youtube" D.string
        |> required "image" D.string
        |> required "events" (D.list eventDecoder)
        |> required "rants" (D.list rantDecoder)


eventDecoder : D.Decoder Event
eventDecoder =
    D.map4 Event
        (D.field "title" D.string)
        (D.field "text" D.string)
        (D.field "source" sourceDecoder)
        (D.field "image" D.string)


rantDecoder : D.Decoder Rant
rantDecoder =
    D.map2 Rant
        (D.field "text" D.string)
        (D.field "source" (D.maybe sourceDecoder))


sourceDecoder : D.Decoder Source
sourceDecoder =
    D.map2 Source
        (D.field "name" D.string)
        (D.field "url" D.string)



--- Other functions -------------------------------------------------------------


defaultStory : Story
defaultStory =
    { bible = "<default>"
    , name = "<default>"
    , ref = "<default>"
    , utter = "<default>"
    , context = "Bolsonaro, Deputado Federal"
    , youtube = ""
    , image = ""
    , events = []
    , rants = []
    }
