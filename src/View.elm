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

                FinishPage showLinks ->
                    viewFinishPage showLinks

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
        False
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
            , div [ class "ContentBox-controls" ] [ Ui.fab Next "fas fa-chevron-right" ]
            ]
        )


viewStory : Story -> Html Msg
viewStory st =
    Ui.appLayout
        st.image
        True
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

        backCover =
            a [ onClick ToggleRants, href "#" ]
                [ i [ class "fas fa-chevron-left" ] []
                , text " voltar"
                ]

        navChildren =
            if List.isEmpty st.rants then
                [ backCover ]

            else
                [ backCover
                , text " | "
                , a [ onClick ToggleEvents, href "#" ]
                    [ text "consequências "
                    , i [ class "fas fa-chevron-right" ] []
                    ]
                ]
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
                ++ [ div [ class "Rants-nav" ] navChildren ]
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


viewFinishPage : Bool -> Html Msg
viewFinishPage showLinks =
    Ui.appLayout
        "/static/facepalm.jpg"
        False
        (Quote
            "E conhecereis a verdade, e a verdade vos libertará."
            "João 8:32"
        )
        (if showLinks then
            viewFinishPageLinks

         else
            viewFinishPageBox
        )


viewFinishPageBox : Html Msg
viewFinishPageBox =
    div [ class "ContentBox", style "transform" "translateY(-40pt)" ]
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
        , p []
            [ a [ href "#", onClick ToggleLinks ] [ text "Saiba mais" ]
            ]
        , div [ class "ContentBox-controls" ] [ Ui.fab Restart "fas fa-redo" ]
        ]


viewFinishPageLinks : Html Msg
viewFinishPageLinks =
    div [ class "ShowEvents" ]
        [ h1 []
            [ span [] [ text "Outras referências" ]
            , a [ href "#", onClick ToggleLinks ] [ i [ class "fas fa-times" ] [] ]
            ]
        , linksList
        , div [ class "back" ]
            [ a [ href "#", onClick ToggleLinks ]
                [ Ui.icon "fas fa-chevron-left", text " voltar" ]
            , text " | "
            , a [ href "#", onClick Next ]
                [ text "reiniciar ", Ui.icon "fas fa-chevron-right" ]
            ]
        ]


linksList : Html Msg
linksList =
    let
        title msg =
            h2 [] [ text msg ]

        item msg source url =
            li []
                [ text (msg ++ " ")
                , a [ href url, target "_blank" ] [ text ("- " ++ source) ]
                ]

        list =
            ul []
    in
    div []
        [ title "Idéias do Bolsonaro"
        , list
            [ item
                "26 Bizarrices que o Bolsonaro disse"
                "Oscar Filho do CQC"
                "https://www.youtube.com/watch?v=DTVALGIYHsc&app=desktop"
            , item
                "Bolsonaro em 5 min"
                "Mídia Ninja"
                "https://www.youtube.com/watch?v=ghCP4r-hzYI&index=5&list=RDDTVALGIYHsc"
            ]
        , title "Valores cristãos"
        , list
            [ item
                "Quem elogia torturador é inimigo de cristo"
                "Leandro Karnal"
                "https://www.youtube.com/watch?v=P069B2xlFBk&index=6&list=RDDTVALGIYHsc"
            , item
                "Bolsonaro Cristão"
                "website"
                "https://www.bolsonarocristao.com/"
            , item
                "Bolsonaro, milícia e o caso Marielle"
                "Policial comenta"
                "https://www.youtube.com/watch?v=nQ7kNOAj8YM&index=22&list=RDDTVALGIYHsc"
            ]
        , title "Manipulação e Fake News"
        , list
            [ item "dfsd" "fdfd" "dfdsoif"
            , item
                "Relações de Bolsonaro e técnicas de manipulação das urnas usando redes sociais (Bolsonaro e Trump)"
                "Canal do Slow"
                "https://www.youtube.com/watch?v=VUTiRx9wD34"
            ]
        , title "Autoritarismo"
        , list
            [ item
                "1984: Pilares do Facismo"
                "#meteoro.doc"
                "https://www.youtube.com/watch?v=vgEvVdeT-xs"
            ]
        , title "Junte-se à causa"
        , list
            [ item "Como " "Vira voto" "https://instragram.com/viravoto/"
            ]
        ]


last : List a -> Maybe a
last lst =
    case lst of
        [] ->
            Nothing

        [ x ] ->
            Just x

        x :: tail ->
            last tail
