module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy)
import Model exposing (..)
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

        revealClass =
            case m.transition of
                FromLeft ->
                    "FromLeft"

                FromRight ->
                    "FromRight"

                Neutral ->
                    "Reveal"

                ClearTransition ->
                    "ResetAnimation"
    in
    div [ class revealClass ]
        (Ui.styleElements ++ [ content ])


viewIntroPage : Html Msg
viewIntroPage =
    Ui.appLayout
        "/static/cruz.jpg"
        (Quote
            """
            E surgirão muitos falsos profetas e enganarão muitos. 
            E, por se multiplicar a iniquidade, o amor de muitos se esfriará.
            """
            "Mateus 24:11-12"
        )
        (div [ class "ContentBox delay" ]
            [ h1 []
                [ text "A política brasileira está cheia de falsos profetas." ]
            , p []
                [ text "Eles se dizem cristãos, mas na verdade propagam a intolerância. O deputado "
                , strong [] [ text "Jair Messias Bolsonaro" ]
                , text " é um deles."
                ]
            , a
                [ href "#", onClick Next ]
                [ text "saiba mais" ]
            , div [class "ContentBox-controls"] [Ui.fab Next "fas fa-chevron-right"]
            ]
        )


viewStory : Story -> Html Msg
viewStory st =
    Ui.appLayout
        st.image
        (Quote st.bible st.ref)
        (if st.state == ShowEvents then
            viewEvents st

         else if st.state == ShowVideo then
            showVideoOverlay st

         else
            viewShowMore st
        )


viewShowMore : Story -> Html Msg
viewShowMore st =
    let
        showMoreClass =
            case st.state of
                ShowRants ->
                    class "ContentBox ContentBox--rants"

                _ ->
                    class "ContentBox"
    in
    div [ showMoreClass ]
        [ p [ style "color" "#000b" ] [ text "o que diz Jair..." ]
        , div [] [ q [] [ text st.utter ] ]
        , Html.cite [ style "color" "#000b" ]
            [ text ("- " ++ st.context)
            ]
        , div []
            [ Ui.icon "fab fa-youtube"
            , text " "
            , a [ href "#", onClick ToggleVideo ]
                [ text "veja o vídeo" ]
            ]
        , div [ class "ContentBox-controls" ]
            [ Ui.fab Prev "fas fa-chevron-left"
            , Ui.fab ToggleRants
                (if st.state == ShowRants then
                    "fas fa-minus"

                 else
                    "fas fa-plus"
                )
            , Ui.fab Next "fas fa-chevron-right"
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
                            [ text "consequências "
                            , i [ class "fas fa-chevron-right" ] []
                            ]
                        ]
                   ]
            )
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
    Ui.appLayout
        "/static/facepalm.jpg"
        (Quote
            "E conhecereis a verdade, e a verdade vos libertará."
            "João 8:32"
        )
        (div [ class "ContentBox" ]
            [ h1 [] [ text "Sobre nós" ]
            , p []
                [ text
                    """
            Expomos falas e comportamentos de Jair Bolsonaro em sua
            tragetória política e vida pública usando vídeos e textos da 
            imprensa nacional (sempre linkados), confrontando-os com passagens 
            da Bíblia. 
            """
                ]
            , p []
                [ text "Tire suas próprias conclusões: Bolsonaro pauta sua vida por valores "
                , strong [] [ text "democráticos e cristãos?" ]
                ]
            , div [class "ContentBox-controls"] [Ui.fab Next "fas fa-redo"]
            ]
        )


last : List a -> Maybe a
last lst =
    case lst of
        [] ->
            Nothing

        [ x ] ->
            Just x

        x :: tail ->
            last tail
