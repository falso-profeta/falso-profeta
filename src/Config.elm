module Config exposing (..)

import Array exposing (Array)
import Browser.Navigation as Nav exposing (Key)
import Dict exposing (Dict)
import Story exposing (Story)


type alias Model =
    { navKey : Key, storyDb : Dict String StoryDbEntry }


type Msg
    = OnSaveStories (List Story)


type alias StoryDbEntry =
    { story : Story
    , next : String
    , prev : String
    }


init : Key -> Model
init key =
    { navKey = key
    , storyDb = Dict.empty
    }


update : Msg -> Model -> Model
update (OnSaveStories sts) m =
    setStories sts m


setStories : List Story -> Model -> Model
setStories sts m =
    { m | storyDb = storyDbFromList sts }


pushUrl : String -> Model -> Cmd msg
pushUrl url m =
    Nav.pushUrl m.navKey url


storyDbFromList : List Story -> Dict String StoryDbEntry
storyDbFromList sts =
    let
        do xs acc prev =
            case xs of
                [] ->
                    acc

                x :: ys ->
                    let
                        next =
                            List.head ys |> Maybe.map (\h -> h.name) |> Maybe.withDefault "final"

                        entry =
                            { story = x, next = next, prev = prev }
                    in
                    do ys (( x.name, entry ) :: acc) x.name
    in
    Dict.fromList <| do sts [] ""


getStory : String -> Model -> Maybe Story
getStory k cfg =
    Maybe.map (\x -> x.story) <| getEntry k cfg


getEntry : String -> Model -> Maybe StoryDbEntry
getEntry k cfg =
    Dict.get k cfg.storyDb


getNextStory : String -> Model -> Maybe String
getNextStory k cfg =
    getEntry k cfg |> Maybe.map (\x -> x.next)


getPrevStory : String -> Model -> Maybe String
getPrevStory k cfg =
    getEntry k cfg |> Maybe.map (\x -> x.prev)


firstStory : Model -> Maybe String
firstStory cfg =
    Dict.toList cfg.storyDb
        |> List.filter (\( _, x ) -> x.prev == "")
        |> List.head
        |> Maybe.map (\( _, x ) -> x.story.name)
