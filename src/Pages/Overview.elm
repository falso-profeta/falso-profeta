module Pages.Overview exposing (Model, Msg(..), init, update, view)

import Browser.Navigation exposing (Key, pushUrl)
import Config as Cfg
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Process
import Task
import Types exposing (Quote(..))
import Ui


type alias Model =
    { state : State
    , cfg : Cfg.Model
    }


type State
    = ViewLinks
    | ViewOverview


type Msg
    = ToggleState
    | NavTo String


init : Cfg.Model -> Model
init cfg =
    Model ViewOverview cfg


toggle m =
    case m.state of
        ViewLinks ->
            { m | state = ViewOverview }

        ViewOverview ->
            { m | state = ViewLinks }


view : Model -> Html Msg
view m =
    let
        quote =
            Quote
                "E conhecereis a verdade, e a verdade vos libertará."
                "João 8:32"

        content =
            case m.state of
                ViewLinks ->
                    viewLinks

                ViewOverview ->
                    viewOverview
    in
    Ui.appShell "./static/facepalm.jpg" Ui.emptyNav quote content


update : Msg -> Model -> ( Model, Cmd Msg )
update msg m =
    case msg of
        ToggleState ->
            ( toggle m, Cmd.none )

        NavTo url ->
            ( m, Cfg.pushUrl url m.cfg )


viewOverview : Html Msg
viewOverview =
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
            [ a [ href "#", onClick ToggleState ] [ text "Saiba mais" ]
            ]
        , div [ class "ContentBox-controls" ] [ Ui.fab (NavTo "/") "fas fa-redo" ]
        ]


viewLinks : Html Msg
viewLinks =
    div [ class "Events" ]
        [ h1 []
            [ span [] [ text "Outras referências" ]
            , a [ href "#", onClick ToggleState ] [ i [ class "fas fa-times" ] [] ]
            ]
        , viewLinkList
        , div [ class "back" ]
            [ a [ href "#", onClick ToggleState ]
                [ Ui.icon "fas fa-chevron-left", text " voltar" ]
            , text " | "
            , a [ href "#", onClick (NavTo "/") ]
                [ text "reiniciar ", Ui.icon "fas fa-chevron-right" ]
            ]
        ]


viewLinkList : Html Msg
viewLinkList =
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
                "Bolsonaro em 5 min"
                "Mídia Ninja"
                "https://www.youtube.com/watch?v=ghCP4r-hzYI&index=5&list=RDDTVALGIYHsc"
            , item
                "26 Bizarrices que o Bolsonaro disse"
                "Oscar Filho do CQC"
                "https://www.youtube.com/watch?v=DTVALGIYHsc&app=desktop"
            ]
        , title "Bolsonaro vs a palavra de cristo"
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
        , title "Autoritarismo e violência"
        , list
            [ item
                "1984: Pilares do Facismo"
                "#meteoro.doc"
                "https://www.youtube.com/watch?v=vgEvVdeT-xs"
            , item
                "Relações de Bolsonaro e técnicas de manipulação das urnas usando redes sociais (Bolsonaro e Trump)"
                "Canal do Slow"
                "https://www.youtube.com/watch?v=VUTiRx9wD34"
            ]
        , title "Junte-se à causa"
        , list
            [ item "Como " "Vira voto" "https://instragram.com/viravoto/"
            ]
        ]
