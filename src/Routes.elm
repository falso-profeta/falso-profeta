module Routes exposing (Route(..), parseUrl, toHref)

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser)


type Route
    = Intro
    | Error String
    | ViewStory String
    | Overview


matchers : Parser (Route -> a) a
matchers =
    Parser.oneOf
        [ Parser.map Intro Parser.top
        , Parser.map Overview (Parser.s "final")
        , Parser.map ViewStory Parser.string
        ]


parseUrl : Url -> Route
parseUrl url =
    case Parser.parse matchers url of
        Just route ->
            route

        Nothing ->
            Error (Url.toString url)


toHref : Route -> String
toHref route =
    case route of
        Error st ->
            "/" ++ st

        Intro ->
            "/"

        Overview ->
            "/final"

        ViewStory st ->
            "/" ++ st
