module View exposing (view)

import Bootstrap.Button as Btn
import Bootstrap.CDN as CDN
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy)
import Markdown
import Model exposing (..)
import Style exposing (..)
import Ui
import Update exposing (Msg(..))


view : Model -> Html.Html Msg
view m =
    let
        content =
            case m.state of
                IntroPage ->
                    viewIntroPage

                ShowStory ->
                    viewStory (readStory m)

                FinishPage ->
                    viewFinishPage
    in
    div []
        (Ui.styleElements
            ++ [ Ui.appWrapper [ content ]
               ]
        )


viewIntroPage : Html Msg
viewIntroPage =
    Ui.quoteLayout
        "intro"
        "/static/cruz.jpg"
        (Quote
            """
            E surgirão muitos falsos profetas e enganarão muitos. 
            E, por se multiplicar a iniquidade, o amor de muitos se esfriará.
            """
            "Mateus 24:11-12"
        )
        (div [ class "ShowMore delay" ]
            [ h1 []
                [ text "A política do Brasil está cheia de falsos profetas." ]
            , p []
                [ text
                    "O deputado Jair Messias Bolsonaro é um deles."
                ]
            , a
                [ href "#", onClick Next ]
                [ text "saiba mais" ]
            , Ui.fab Next "fas fa-chevron-right"
            ]
        )


viewStory : Story -> Html Msg
viewStory st =
    Ui.quoteLayout
        (storyId st)
        st.image
        (Quote st.bible st.ref)
        (if st.state == ShowEvents then
            viewEvents st

         else
            viewShowMore st
        )


viewShowMore : Story -> Html Msg
viewShowMore st =
    let
        showMoreClass =
            case st.state of
                ShowRants ->
                    class "ShowMore rants"

                _ ->
                    class "ShowMore"
    in
    div [ showMoreClass ]
        [ p [ style "color" "#000b" ] [ text "o que diz Jair..." ]
        , div [] [ q [] [ text st.utter ] ]
        , Html.cite [ style "color" "#000b" ]
            [ text "- Jair Messias Bolsonaro, Deputado Federal"
            ]
        , div []
            [ Ui.icon "fab fa-youtube"
            , text " "
            , a [ href "#", onClick ToggleVideo ]
                [ text "veja o vídeo" ]
            , Ui.fab ToggleRants
                (if st.state == ShowRants then
                    "fas fa-minus"

                 else
                    "fas fa-plus"
                )
            ]
        , div [ class "Rants" ]
            (List.map viewRant st.rants
                ++ [ div [ class "Rants-nav" ]
                        [ a [ onClick ToggleRants, href "#" ]
                            [ i [ class "fas fa-chevron-left" ] []
                            , text " voltar"
                            ]
                        , text " | "
                        , a [ onClick ToggleEvents, href "#" ]
                            [ text "seus seguidores "
                            , i [ class "fas fa-chevron-right" ] []
                            ]
                        ]
                   ]
            )
        , showVideoOverlay st
        ]


showVideoOverlay : Story -> Html Msg
showVideoOverlay st =
    let
        cls =
            case st.state of
                ShowVideo ->
                    "Video"

                _ ->
                    "Video hidden"
    in
    div [ class cls ]
        [ div [ class "Video-overlay" ] []
        , div [ class "Video-content" ]
            [ Ui.youtubeIframe "" st.youtube
            , div []
                [ Ui.fab Prev "fas fa-chevron-left"
                , Ui.fab ToggleVideo "fas fa-times"
                , Ui.fab Next "fas fa-chevron-right"
                ]
            ]
        ]


viewRant : Rant -> Html msg
viewRant rant =
    let
        links =
            case rant.source of
                Just { name, url } ->
                    [ Html.cite []
                        [ text "- veja mais: "
                        , a [ href url, target "_blank" ] [ text name ]
                        ]
                    ]

                Nothing ->
                    []
    in
    div []
        (q [] [ text rant.text ] :: links)


viewEvents : Story -> Html Msg
viewEvents st =
    lazy
        (\events ->
            div [ class "ShowEvents" ]
                [ h1 []
                    [ span [] [ text "Efeito Bolsonaro" ]
                    , a [ href "#", onClick ToggleEvents ] [ i [ class "fas fa-times" ] [] ]
                    ]
                , div [] (List.map viewEvent events)
                , div [ class "back" ]
                    [ a [ href "#", onClick ToggleEvents ]
                        [ Ui.icon "fas fa-chevron-left", text " voltar" ]
                    , text " | "
                    , a [ href "#", onClick Next ]
                        [ text "próxima história ", Ui.icon "fas fa-chevron-right" ]
                    ]
                ]
        )
        st.events


viewEvent : Event -> Html Msg
viewEvent { title, text, source, image } =
    let
        link elem =
            a [ href source.url, target "_blank", alt source.name ] [ elem ]
    in
    div [ class "Event" ]
        [ link (h2 [] [ Html.text title ])
        , link (img [ src image ] [])
        , Html.text text
        , viewSource source
        ]


viewSource : Source -> Html msg
viewSource { name, url } =
    Html.cite [] [ text "Fonte: ", a [ href url ] [ text name ] ]


viewFinishPage : Html Msg
viewFinishPage =
    Ui.quoteLayout
        "finish"
        "/static/facepalm.jpg"
        (Quote
            """
         Se vocês fossem cegos, não teriam culpa! Mas como dizem que podem ver, 
         então continuam tendo culpa.         """
            "João 9:41"
        )
        (div [ class "ShowMore" ]
            [ h1 [] [ text "Sobre nós" ]
            , p [] [ text "balsoaos " ]
            ]
        )


storyId : Story -> String
storyId st =
    "story-" ++ (last (String.split "/" st.youtube) |> Maybe.withDefault "youtube")


last : List a -> Maybe a
last lst =
    case lst of
        [] ->
            Nothing

        [ x ] ->
            Just x

        x :: tail ->
            last tail



--- MARKDOWN CONTENT -----------------------------------------------------------


md : List (Html.Attribute msg) -> String -> Html msg
md attrs src =
    Markdown.toHtml attrs src



-- |> Html.Styled.fromUnstyled


introContent : Html msg
introContent =
    md [] """
# Bolsonaro é fiel

Bolsonaro é um péssimo deputado e pessoa.
"""
