module Routes exposing (Route(..), parseUrl, toHref, trimRoute)

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
    let
        path =
            "/" ++ trimRoute (Maybe.withDefault "" url.fragment)
    in
    case Parser.parse matchers { url | path = path, query = Nothing, fragment = Nothing } of
        Just route ->
            route

        Nothing ->
            Error (trimRoute (Maybe.withDefault "" url.fragment))


{-| Normaliza "#/ira", "/ira" ou "ira" para "ira". O site usa rotas no
fragmento da URL, para funcionar em qualquer subcaminho (GitHub Pages).
-}
trimRoute : String -> String
trimRoute st =
    let
        dropPrefix prefix x =
            if String.startsWith prefix x then
                String.dropLeft (String.length prefix) x

            else
                x
    in
    st |> dropPrefix "#" |> dropPrefix "/"


toHref : Route -> String
toHref route =
    case route of
        Error st ->
            "#/" ++ st

        Intro ->
            "#/"

        Overview ->
            "#/final"

        ViewStory st ->
            "#/" ++ st
