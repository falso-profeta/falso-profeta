module Pages.Story exposing (Model, Msg, init, update, view)

import Array exposing (Array)
import Config as Cfg
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Ev
import Html.Lazy exposing (lazy)
import Process
import Story exposing (Event, Rant, Source, Story)
import Task
import Types exposing (Quote(..), Transition(..), transitionDuration)
import Ui


type State
    = Init
    | Expanded
    | Events
    | Video


type Msg
    = ToState State
    | OnNextStory
    | OnPrevStory
    | OnResetStory
    | OnPreTransition Transition Msg
    | OnPostTransition Transition Msg
    | OnResetTransition


type alias Model =
    { story : Story
    , state : State
    , transition : Transition
    , cfg : Cfg.Model
    }


init : Story -> Cfg.Model -> Model
init st cfg =
    { story = st, cfg = cfg, state = Init, transition = NoTransition }


toggleEvents : State -> Msg
toggleEvents st =
    case st of
        Events ->
            ToState Expanded

        _ ->
            ToState Events


toggleExpanded : State -> Msg
toggleExpanded st =
    case st of
        Expanded ->
            ToState Init

        _ ->
            ToState Expanded


toggleVideo : State -> Msg
toggleVideo st =
    case st of
        Video ->
            ToState Init

        _ ->
            ToState Video


update : Msg -> Model -> ( Model, Cmd Msg )
update msg m =
    case msg of
        ToState st ->
            ( { m | state = st }, Cmd.none )

        OnResetTransition ->
            ( { m | transition = Reset }, Cmd.none )

        OnPreTransition step nextMsg ->
            ( { m | transition = step }, Task.perform (\_ -> nextMsg) (Process.sleep (transitionDuration step)) )

        OnPostTransition step nextMsg ->
            let
                ( new, cmd ) =
                    update nextMsg m

                task =
                    Task.perform (\_ -> OnResetTransition) (Process.sleep (transitionDuration step))
            in
            ( { new | transition = step }, Cmd.batch [ task, cmd ] )

        OnNextStory ->
            let
                url =
                    Cfg.getNextStory m.story.name m.cfg |> Maybe.withDefault "final"
            in
            ( m, Cfg.pushUrl url m.cfg )

        OnPrevStory ->
            let
                url =
                    Cfg.getPrevStory m.story.name m.cfg |> Maybe.withDefault ""
            in
            ( m, Cfg.pushUrl url m.cfg )

        OnResetStory ->
            ( m, Cfg.pushUrl "" m.cfg )


view : Model -> Html Msg
view m =
    let
        quote =
            Quote m.story.bible m.story.ref

        content =
            case m.state of
                Init ->
                    viewExpandedOrInit False m

                Expanded ->
                    viewExpandedOrInit True m

                Events ->
                    viewEvents m

                Video ->
                    viewVideo m
    in
    Ui.appShell ("." ++ m.story.image) (Ui.navLinks OnResetStory) quote content


viewExpandedOrInit : Bool -> Model -> Html Msg
viewExpandedOrInit expand m =
    let
        st =
            m.story

        ( parentClass, fabMiddle ) =
            if expand then
                ( "ContentBox ContentBox--rants", Ui.fab (toggleExpanded m.state) "fas fa-minus" )

            else
                ( "ContentBox", Ui.fabText (toggleExpanded m.state) "saiba mais" )

        backCover =
            a [ Ev.onClick (toggleExpanded m.state), href "#" ]
                [ i [ class "fas fa-chevron-left" ] []
                , text " voltar"
                ]

        navChildren =
            if List.isEmpty st.rants then
                [ backCover ]

            else
                [ backCover
                , text " | "
                , a [ Ev.onClick (toggleEvents m.state), href "#" ]
                    [ text "notícias "
                    , i [ class "fas fa-chevron-right" ] []
                    ]
                ]
    in
    div [ class parentClass ]
        [ div [] [ q [] [ text st.utter ] ]
        , Html.cite [ style "color" "#000b" ]
            [ text ("- " ++ st.context)
            ]
        , div [ style "margin-bottom" "1em" ]
            [ a [ href "#", Ev.onClick (toggleVideo m.state) ]
                [ Ui.icon "fab black fa-youtube", text " veja o vídeo" ]
            ]
        , div [ class "ContentBox-controls" ]
            [ Ui.fab (fadeAndThen FromRight OnPrevStory) "fas fa-chevron-left"
            , fabMiddle
            , Ui.fab (fadeAndThen FromLeft OnNextStory) "fas fa-chevron-right"
            ]
        , div [ class "Rants" ]
            (List.map viewRant st.rants
                ++ [ div [ class "Rants-nav" ] navChildren ]
            )
        ]


viewEvents : Model -> Html Msg
viewEvents m =
    lazy
        (\events ->
            div [ class "Events" ]
                [ h1 []
                    [ span [] [ text "Efeito Bolsonaro" ]
                    , a [ href "#", Ev.onClick (toggleEvents m.state) ] [ i [ class "fas fa-times" ] [] ]
                    ]
                , div [] (List.map viewEvent events)
                , div [ class "back" ]
                    [ a [ href "#", Ev.onClick (toggleEvents m.state) ]
                        [ Ui.icon "fas fa-chevron-left", text " voltar" ]
                    , text " | "
                    , a [ href "#", Ev.onClick OnNextStory ]
                        [ text "próxima história ", Ui.icon "fas fa-chevron-right" ]
                    ]
                ]
        )
        m.story.events


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


viewVideo : Model -> Html Msg
viewVideo m =
    div [ class "Video" ]
        [ div [ class "Video-overlay" ] []
        , div [ class "Video-content" ]
            [ Ui.youtubeIframe "" m.story.youtube
            , div []
                [ Ui.fab OnPrevStory "fas fa-chevron-left"
                , Ui.fab (toggleVideo m.state) "fas fa-times"
                , Ui.fab OnNextStory "fas fa-chevron-right"
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


viewSource : Source -> Html msg
viewSource { name, url } =
    Html.cite [] [ text "Fonte: ", a [ href url ] [ text name ] ]


last : List a -> Maybe a
last lst =
    case lst of
        [] ->
            Nothing

        [ x ] ->
            Just x

        x :: tail ->
            last tail


fadeAndThen : Transition -> Msg -> Msg
fadeAndThen trans msg =
    OnPreTransition FadeOut (OnPostTransition trans msg)
